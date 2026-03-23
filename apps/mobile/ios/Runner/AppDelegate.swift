import Flutter
import UIKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {
    
    private var flutterChannel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
print("🚀🚀🚀 APP DELEGATE STARTED 🚀🚀🚀")  // ← ضيف ده
    
    GeneratedPluginRegistrant.register(with: self)
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        // ✅ استنى الـ UI يتجهز بـ timer
        setupFlutterChannelWhenReady()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupFlutterChannelWhenReady() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard self.flutterChannel == nil else { return }
            
            // ✅ ابحث في كل الـ scenes والـ windows
            var found = false
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows {
                    if let controller = window.rootViewController as? FlutterViewController {
                        self.flutterChannel = FlutterMethodChannel(
                            name: "com.mahfazti.watch/connector",
                            binaryMessenger: controller.binaryMessenger
                        )
                        self.flutterChannel?.setMethodCallHandler { [weak self] call, result in
                            if call.method == "sendDataToWatch",
                               let args = call.arguments as? [String: Any] {
                                self?.sendDataToWatch(args)
                                result(true)
                            } else {
                                result(FlutterMethodNotImplemented)
                            }
                        }
                        print("✅ Flutter channel ready!")
                        found = true
                        break
                    }
                }
                if found { break }
            }
            
            if !found {
                print("❌ Not found yet, retrying...")
                self.setupFlutterChannelWhenReady()
            }
        }
    }
    
    // ── استقبال Messages من الـ Watch ──
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard let action = message["action"] as? String else {
            replyHandler(["error": "no action"])
            return
        }
        print("📱 Watch → iPhone: \(action)")
        
        DispatchQueue.main.async { [weak self] in
            guard let channel = self?.flutterChannel else {
                print("❌ Channel not ready!")
                replyHandler(["error": "channel not ready"])
                return
            }
            switch action {
            case "getHomeData":
                channel.invokeMethod("getHomeData", arguments: nil) { result in
                    print("📱 Flutter replied: \(String(describing: result))")
                    if let data = result as? [String: Any] {
                        replyHandler(data)
                    } else {
                        replyHandler(["totalBalance": 0.0, "totalDeposits": 0.0, "totalWithdrawals": 0.0, "recentTransactions": []])
                    }
                }
            case "parseVoice":
                let text = message["text"] as? String ?? ""
                let language = message["language"] as? String ?? "en"
                channel.invokeMethod("parseVoice", arguments: ["text": text, "language": language]) { result in
                    replyHandler(result as? [String: Any] ?? ["isSuccess": false])
                }
            case "addTransaction":
                let amount = (message["amount"] as? NSNumber)?.doubleValue ?? 0
                let type = message["type"] as? String ?? "Withdrawal"
                let category = message["category"] as? String ?? "Other"
                channel.invokeMethod("addTransaction", arguments: ["amount": amount, "type": type, "category": category]) { result in
                    replyHandler(["success": result as? Bool ?? false])
                }
            default:
                replyHandler(["error": "unknown action"])
            }
        }
    }
    
    private func sendDataToWatch(_ data: [String: Any]) {
        guard WCSession.default.activationState == .activated else { return }
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(data, replyHandler: nil) { error in
                print("Send error: \(error)")
            }
        } else {
            try? WCSession.default.updateApplicationContext(data)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        print("📱 WCSession: \(state.rawValue)")
    }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
