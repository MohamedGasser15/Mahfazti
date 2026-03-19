//
//  WatchConnector.swift
//  MahfaztiWatch Watch App
//

import Foundation
import WatchConnectivity
import Combine
class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var balance: Double = 0.0
    @Published var totalIncome: Double = 0.0
    @Published var totalExpense: Double = 0.0
    @Published var recentTransactions: [WatchTransaction] = []
    @Published var isLoading = false
    @Published var isParsing = false
    @Published var isLoggedIn = true
    @Published var errorMessage: String? = nil
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    private var retryCount = 0
    private let maxRetries = 3

    func requestData() {

        if !WCSession.default.isReachable {
            if retryCount < maxRetries {
                retryCount += 1
                print("Watch not reachable, retry \(retryCount) in 2s...")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.requestData()
                }
            } else {
                print("Watch unreachable after \(maxRetries) retries")
            }
            return
        }

        retryCount = 0
        isLoading = true
        errorMessage = nil

        WCSession.default.sendMessage(
            ["action": "getHomeData"],
            replyHandler: { [weak self] reply in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    if let status = reply["status"] as? String, status == "unauthorized" {
                        self?.isLoggedIn = false
                        return
                    }

                    self?.isLoggedIn = true
                    self?.handleHomeData(reply)
                }
            },
            errorHandler: { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    print("Watch request error: \(error)")
                }
            }
        )
    }
    
    func parseVoiceText(_ text: String, completion: @escaping (Double?, String, String) -> Void) {
        guard WCSession.default.isReachable else {
            completion(nil, "Other", "Withdrawal")
            return
        }
        
        isParsing = true
        
        WCSession.default.sendMessage(
            ["action": "parseVoice", "text": text, "language": "en"],
            replyHandler: { [weak self] reply in
                DispatchQueue.main.async {
                    self?.isParsing = false
                    // ✅ handle NSNumber vs Double
                    let amount = (reply["amount"] as? NSNumber)?.doubleValue
                    let category = reply["categoryNameEn"] as? String ?? "Other"
                    let type = reply["transactionType"] as? String ?? "Withdrawal"
                    completion(amount, category, type)
                }
            },
            errorHandler: { [weak self] error in
                DispatchQueue.main.async {
                    self?.isParsing = false
                    print("Parse error: \(error)")
                    completion(nil, "Other", "Withdrawal")
                }
            }
        )
    }
    
    func addTransaction(amount: Double, type: String, category: String, completion: @escaping (Bool) -> Void) {
        guard WCSession.default.isReachable else {
            completion(false)
            return
        }
        
        WCSession.default.sendMessage(
            ["action": "addTransaction", "amount": amount, "type": type, "category": category],
            replyHandler: { reply in
                DispatchQueue.main.async {
                    let success = reply["success"] as? Bool ?? false
                    completion(success)
                }
            },
            errorHandler: { error in
                DispatchQueue.main.async {
                    print("Add error: \(error)")
                    completion(false)
                }
            }
        )
    }
    
    private func handleHomeData(_ data: [String: Any]) {
        // ✅ handle NSNumber vs Double
        balance = (data["totalBalance"] as? NSNumber)?.doubleValue ?? 0
        totalIncome = (data["totalDeposits"] as? NSNumber)?.doubleValue ?? 0
        totalExpense = (data["totalWithdrawals"] as? NSNumber)?.doubleValue ?? 0
        
        if let transactions = data["recentTransactions"] as? [[String: Any]] {
            recentTransactions = transactions.compactMap { t in
                guard
                    let id = t["id"] as? Int,
                    let title = t["title"] as? String,
                    let amount = (t["amount"] as? NSNumber)?.doubleValue,
                    let type = t["type"] as? String
                else { return nil }
                
                return WatchTransaction(
                    id: id,
                    title: title,
                    amount: amount,
                    category: t["categoryNameEn"] as? String ?? "",
                    isIncome: type == "Deposit"
                )
            }
        }
    }
    
    // ── WCSessionDelegate ──
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        print("WCSession activated: \(state.rawValue)")
        if state == .activated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.requestData()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String, action == "dataUpdate" {
                self.handleHomeData(message)
            }
        }
    }
    
    // ✅ استقبال applicationContext لو الـ iPhone بعت البيانات تلقائي
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.handleHomeData(applicationContext)
        }
    }
}
