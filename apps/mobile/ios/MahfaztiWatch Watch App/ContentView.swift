//
//  ContentView.swift
//  MahfaztiWatch Watch App
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var connector = WatchConnector()
    @State private var showAddSheet = false
    
    var body: some View {
        Group {
            if !connector.isLoggedIn {
                // ── Not Logged In ──
                notLoggedInView
            } else {
                // ── Main View ──
                mainView
            }
        }
        .onAppear {
            connector.requestData()
        }
    }
    
    // ── Not Logged In View ──
    var notLoggedInView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Not Logged In")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Please open Mahfazti on your iPhone and log in first.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding()
    }
    
    // ── Main View ──
    var mainView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    
                    // ── Balance Card ──
                    balanceCard
                    Button {
                        connector.requestData()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    // ── Add by Voice ──
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add by Voice", systemImage: "mic.fill")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    // ── Recent Transactions ──
                    if !connector.recentTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Recent")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            ForEach(connector.recentTransactions) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    } else if !connector.isLoading {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("No transactions yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    
                    // ── Retry Button ──
                    if connector.errorMessage != nil {
                        Button {
                            connector.requestData()
                        } label: {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(.orange, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 80)
            }
            .navigationTitle("💰 Mahfazti")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView(connector: connector)
        }
    }
    
    // ── Balance Card ──
    var balanceCard: some View {
        VStack(spacing: 6) {
            if connector.isLoading {
                ProgressView()
                    .scaleEffect(0.9)
                    .padding()
            } else {
                Text("Total Balance")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("$\(connector.balance, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                Divider()
                    .padding(.vertical, 2)
                
                HStack(spacing: 0) {
                    // Income
                    VStack(spacing: 2) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 9))
                                .foregroundStyle(.green)
                            Text("Income")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        Text("$\(connector.totalIncome, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 28)
                    
                    // Expense
                    VStack(spacing: 2) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 9))
                                .foregroundStyle(.red)
                            Text("Expense")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        Text("$\(connector.totalExpense, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// ── Transaction Row ──
struct TransactionRow: View {
    let transaction: WatchTransaction
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .frame(width: 26, height: 26)
                .overlay {
                    Image(systemName: transaction.isIncome ? "arrow.down" : "arrow.up")
                        .font(.system(size: 10))
                        .foregroundStyle(transaction.isIncome ? .green : .red)
                }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(transaction.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(transaction.category)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 4)
            
            Text("\(transaction.isIncome ? "+" : "-")$\(transaction.amount, specifier: "%.0f")")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(transaction.isIncome ? .green : .red)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

// ── Add Transaction View ──
struct AddTransactionView: View {
    @ObservedObject var connector: WatchConnector
    @Environment(\.dismiss) var dismiss
    
    @State private var dictatedText = ""
    @State private var parsedAmount: Double? = nil
    @State private var parsedCategory = ""
    @State private var parsedType = "Withdrawal"
    @State private var step: AddStep = .voice
    @State private var isSubmitting = false
    
    enum AddStep { case voice, confirm, success }
    
    var body: some View {
        switch step {
        case .voice:    voiceView
        case .confirm:  confirmView
        case .success:  successView
        }
    }
    
    // ── Voice Screen ──
    var voiceView: some View {
        VStack(spacing: 12) {
            Text("Say your transaction")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button { startDictation() } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .shadow(color: .blue.opacity(0.4), radius: 8)
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            
            if !dictatedText.isEmpty {
                Text(dictatedText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 4)
            }
            
            if connector.isParsing {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7)
                    Text("Analyzing...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
    
    // ── Confirm Screen ──
    var confirmView: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Confirm")
                    .font(.callout)
                    .fontWeight(.bold)
                
                VStack(spacing: 2) {
                    Text(parsedType == "Deposit" ? "Income" : "Expense")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("$\(parsedAmount ?? 0, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(parsedType == "Deposit" ? .green : .red)
                        .minimumScaleFactor(0.7)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(parsedCategory.isEmpty ? "Other" : parsedCategory)
                        .font(.caption)
                        .lineLimit(1)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                
                HStack(spacing: 6) {
                    Button {
                        step = .voice
                        dictatedText = ""
                    } label: {
                        Text("Redo")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    
                    Button { submitTransaction() } label: {
                        Group {
                            if isSubmitting {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Text("Add ✓")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.green, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSubmitting)
                }
            }
            .padding(8)
        }
    }
    
    // ── Success Screen ──
    var successView: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text("Added!")
                .font(.callout)
                .fontWeight(.bold)
            Text("$\(parsedAmount ?? 0, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(parsedType == "Deposit" ? .green : .red)
        }
        .onAppear {
            WKInterfaceDevice.current().play(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
                connector.requestData()
            }
        }
    }
    
    // ── Functions ──
    func startDictation() {
        #if targetEnvironment(simulator)
        dictatedText = "spent 50 on food"
        parseVoiceText("spent 50 on food")
        #else
        WKExtension.shared().rootInterfaceController?.presentTextInputController(
            withSuggestions: [
                "spent 50 on food",
                "paid 100 for transport",
                "received 500 salary",
                "got 1000 salary"
            ],
            allowedInputMode: .plain
        ) { results in
            if let results = results as? [String], let text = results.first {
                self.dictatedText = text
                self.parseVoiceText(text)
            }
        }
        #endif
    }
    
    func parseVoiceText(_ text: String) {
        connector.parseVoiceText(text) { amount, category, type in
            parsedAmount = amount
            parsedCategory = category
            parsedType = type
            step = .confirm
        }
    }
    
    func submitTransaction() {
        guard let amount = parsedAmount else { return }
        isSubmitting = true
        connector.addTransaction(amount: amount, type: parsedType, category: parsedCategory) { success in
            isSubmitting = false
            if success { step = .success }
        }
    }
}

// ── Models ──
struct WatchTransaction: Identifiable {
    let id: Int
    let title: String
    let amount: Double
    let category: String
    let isIncome: Bool
}

#Preview {
    ContentView()
}
