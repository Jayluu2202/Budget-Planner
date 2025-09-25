//
//  TransactionDetailsView.swift
//  Budget Planner
//
//  Fixed delete functionality with proper TransactionManager integration and edit functionality
//

import SwiftUI
import UIKit
struct TransactionDetailsView: View {
    let transaction: Transaction
    @ObservedObject var transactionManager: TransactionManager
    @StateObject private var currencyManager = CurrencyManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Amount section
            VStack(spacing: 8) {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(amountText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(amountColor)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Transaction details
            VStack(spacing: 0) {
                DetailRow(title: "Date", value: formatDate(transaction.date))
                
                Divider()
                    .padding(.horizontal)
                
                DetailRow(title: "Time", value: formatTime(transaction.date))
                
                Divider()
                    .padding(.horizontal)
                
                DetailRow(
                    title: "Account",
                    value: transaction.account.name,
                    emoji: transaction.account.emoji
                )
                
                Divider()
                    .padding(.horizontal)
                
                DetailRow(
                    title: "Category",
                    value: transaction.category.name,
                    emoji: transaction.category.emoji
                )
                
                if !transaction.description.isEmpty && transaction.description != "No description" {
                    Divider()
                        .padding(.horizontal)
                    
                    DetailRow(title: "Description", value: transaction.description)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    showEditSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Edit")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .navigationTitle("Transaction detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear{
            hideTabBarLegacy()
        }
        .onDisappear{
            showTabBarLegacy()
        }
        .sheet(isPresented: $showEditSheet) {
            EditTransactionView(
                transaction: transaction,
                transactionManager: transactionManager
            )
        }
        .alert("Delete Transaction", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                transactionManager.deleteTransaction(transaction)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    private var amountText: String {
        let appCurrency = currencyManager.selectedCurrency.symbol
        let prefix = transaction.type == .expense ? "-" : "+"
        return "\(prefix)\(appCurrency)\(Int(transaction.amount))"
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension TransactionDetailsView {
    // Updated method for hiding tab bar
    private func hideTabBarLegacy() {
        DispatchQueue.main.async {
            // Method 1: Using scene-based approach (iOS 13+)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = true
                } else {
                    // Method 2: Navigate through view hierarchy
                    findAndHideTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    private func showTabBarLegacy() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = false
                } else {
                    findAndShowTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    // Recursive method to find tab bar controller
    private func findAndHideTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = true
        } else if let navigationController = vc as? UINavigationController {
            findAndHideTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndHideTabBar(in: child)
            }
        }
    }
    
    private func findAndShowTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = false
        } else if let navigationController = vc as? UINavigationController {
            findAndShowTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndShowTabBar(in: child)
            }
        }
    }
}

// MARK: - Edit Transaction View
struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    
    let transaction: Transaction
    @ObservedObject var transactionManager: TransactionManager
    
    @State private var selectedType: TransactionType
    @State private var transactionDate: Date
    @State private var amount: String
    @State private var description: String
    @State private var repeatTransaction: Bool
    
    @StateObject private var accountStore = AccountStore()
    @StateObject private var categoryStore = CategoryStore()
    
    @State private var selectedAccount: Account?
    @State private var selectedCategories: Category?
    
    // Alert states
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(transaction: Transaction, transactionManager: TransactionManager) {
        self.transaction = transaction
        self.transactionManager = transactionManager
        
        // Initialize state variables with transaction data
        _selectedType = State(initialValue: transaction.type)
        _transactionDate = State(initialValue: transaction.date)
        _amount = State(initialValue: String(Int(transaction.amount)))
        _description = State(initialValue: transaction.description)
        _repeatTransaction = State(initialValue: transaction.isRecurring)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented Picker with proper spacing
                VStack(spacing: 16) {
                    Picker("Transaction Type", selection: $selectedType) {
                        ForEach([TransactionType.income, TransactionType.expense, TransactionType.transfer], id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    DatePicker(
                        "",
                        selection: $transactionDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 8)
                
                // Only show income/expense UI (simplified for editing)
                VStack(spacing: 16) {
                    // Amount Input
                    HStack {
                        TextField("0", text: $amount)
                            .font(.largeTitle)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                        let actualCurrency = CurrencyManager().selectedCurrency.code
                        Text("\(actualCurrency)")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    TextField("Add a note", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack {
                        VStack(alignment: .leading){
                            Text("Account")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            if accountStore.accounts.isEmpty {
                                Text("No accounts available")
                            } else {
                                Menu {
                                    ForEach(accountStore.accounts) { account in
                                        Button("\(account.emoji) \(account.name)") {
                                            selectedAccount = account
                                        }
                                    }
                                } label: {
                                    Text(selectedAccount.map { "\($0.emoji) \($0.name)" } ?? "Select Account")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing){
                            Text("Category")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Menu {
                                ForEach(categoryStore.getCategories(for: selectedType == .income ? .income : .expense)) { category in
                                    Button("\(category.emoji) \(category.name)") {
                                        selectedCategories = category
                                    }
                                }
                            } label: {
                                Text(selectedCategories.map {
                                    "\($0.emoji) \($0.name)"} ??
                                     "Select Category")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Toggle(isOn: $repeatTransaction) {
                        Text("Repeat Transaction")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    updateTransaction()
                }) {
                    Text("Update")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .alert("Validation Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadInitialData()
            }
        }
    }
    
    // MARK: - Load Initial Data
    private func loadInitialData() {
        // Set the selected account and category based on the transaction
        selectedAccount = transaction.account
        
        // Find matching category from categoryStore
        let matchingCategory = categoryStore.getCategories(for: selectedType == .income ? .income : .expense)
            .first { $0.name == transaction.category.name && $0.emoji == transaction.category.emoji }
        selectedCategories = matchingCategory
    }
    
    // MARK: - Update Transaction Function
    private func updateTransaction() {
        // Validate input
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        guard let account = selectedAccount else {
            alertMessage = "Please select an account"
            showingAlert = true
            return
        }
        
        guard let category = selectedCategories else {
            alertMessage = "Please select a category"
            showingAlert = true
            return
        }
        
        // Convert Category to TransactionCategory for compatibility
        let transactionCategory = TransactionCategory(
            id: category.id,
            name: category.name,
            emoji: category.emoji,
            type: selectedType == .income ? .income : .expense
        )
        
        // Create updated transaction with the same ID
        let updatedTransaction = Transaction(
            id: transaction.id,
            type: selectedType,
            amount: amountValue,
            description: description.isEmpty ? "No description" : description,
            date: transactionDate,
            account: account,
            category: transactionCategory,
            isRecurring: repeatTransaction
        )
        
        // Update transaction
        transactionManager.updateTransaction(updatedTransaction)
        
        // Dismiss the edit view
        dismiss()
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let emoji: String?
    
    init(title: String, value: String, emoji: String? = nil) {
        self.title = title
        self.value = value
        self.emoji = emoji
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.body)
                }
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
}

struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionDetailsView(
                transaction: sampleTransaction,
                transactionManager: TransactionManager()
            )
        }
    }
    
    static var sampleTransaction: Transaction {
        Transaction(
            type: .expense,
            amount: 300.0,
            description: "Medical expenses",
            date: Date(),
            account: Account(name: "Cash", emoji: "💰"),
            category: TransactionCategory(name: "Health", emoji: "💊", type: .expense),
            isRecurring: false
        )
    }
}
