//
//  TransactionManager.swift
//  Budget Planner
//
//  Updated version with budget integration
//

import Foundation
import SwiftUI

// MARK: - Transaction Manager
class TransactionManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var accounts: [Account] = []
    @Published var categories: [TransactionCategory] = []

    private let transactionsKey = "transactions_key"
    private let accountsKey = "accounts_key"
    private let categoriesKey = "categories_key"
    
    // Budget integration
    var budgetManager: BudgetManager?

    init() {
        loadData()
    }
    
    // Set budget manager for integration
    func setBudgetManager(_ budgetManager: BudgetManager) {
        self.budgetManager = budgetManager
    }

    // MARK: - Data Persistence

    func loadData() {
        loadTransactions()
        loadAccounts()
        loadCategories()
        
        // Add default categories if none exist
        if categories.isEmpty {
            addDefaultCategories()
        }
        
        // Add default accounts if none exist
        if accounts.isEmpty {
            addDefaultAccounts()
        }
    }

    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: data) {
            self.transactions = decodedTransactions
        }
    }

    private func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let decodedAccounts = try? JSONDecoder().decode([Account].self, from: data) {
            self.accounts = decodedAccounts
        }
    }

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([TransactionCategory].self, from: data) {
            self.categories = decodedCategories
        }
    }

    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }

    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
        }
    }

    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }
    
    // MARK: - Default Data Setup
    
    private func addDefaultCategories() {
        let defaultCategories = [
            // Expense categories
            TransactionCategory(name: "Food", emoji: "🍔", type: .expense),
            TransactionCategory(name: "Transport", emoji: "🚗", type: .expense),
            TransactionCategory(name: "Shopping", emoji: "🛍️", type: .expense),
            TransactionCategory(name: "Bills", emoji: "📄", type: .expense),
            TransactionCategory(name: "Entertainment", emoji: "🎮", type: .expense),
            TransactionCategory(name: "Health", emoji: "💊", type: .expense),
            TransactionCategory(name: "Education", emoji: "📚", type: .expense),
            TransactionCategory(name: "Travel", emoji: "✈️", type: .expense),
            
            // Income categories
            TransactionCategory(name: "Salary", emoji: "💰", type: .income),
            TransactionCategory(name: "Freelance", emoji: "💻", type: .income),
            TransactionCategory(name: "Investment", emoji: "📈", type: .income),
            TransactionCategory(name: "Gift", emoji: "🎁", type: .income),
            
            // Transfer categories
            TransactionCategory(name: "Transfer", emoji: "↔️", type: .transfer)
        ]
        
        categories = defaultCategories
        saveCategories()
    }
    
    private func addDefaultAccounts() {
        let defaultAccounts = [
            Account(name: "Cash", emoji: "💵", balance: 0),
            Account(name: "Bank Account", emoji: "🏦", balance: 0),
            Account(name: "Credit Card", emoji: "💳", balance: 0),
            Account(name: "Savings", emoji: "💰", balance: 0)
        ]
        
        accounts = defaultAccounts
        saveAccounts()
    }

    // MARK: - Account Management

    func addAccount(_ account: Account) {
        accounts.append(account)
        saveAccounts()
    }

    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveAccounts()
        }
    }

    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        saveAccounts()

        // Also remove transactions associated with this account
        transactions.removeAll { $0.account.id == account.id }
        saveTransactions()
    }

    // MARK: - Category Management

    func addCategory(_ category: TransactionCategory) {
        categories.append(category)
        saveCategories()
    }

    func updateCategory(_ category: TransactionCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    func deleteCategory(_ category: TransactionCategory) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }

    // MARK: - Transaction Management

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()

        // Update account balance
        updateAccountBalance(for: transaction, isAdding: true)
        
        // Update budget spending if it's an expense
        if transaction.type == .expense {
            budgetManager?.updateBudgetSpending(for: transaction.category, amount: transaction.amount, isAdding: true)
        }
    }

    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            let oldTransaction = transactions[index]

            // Reverse old transaction effects
            updateAccountBalance(for: oldTransaction, isAdding: false)
            if oldTransaction.type == .expense {
                budgetManager?.updateBudgetSpending(for: oldTransaction.category, amount: oldTransaction.amount, isAdding: false)
            }

            // Update transaction
            transactions[index] = transaction
            saveTransactions()

            // Apply new transaction effects
            updateAccountBalance(for: transaction, isAdding: true)
            if transaction.type == .expense {
                budgetManager?.updateBudgetSpending(for: transaction.category, amount: transaction.amount, isAdding: true)
            }
        }
    }

    func deleteTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions.remove(at: index)
            saveTransactions()

            // Reverse the balance change
            updateAccountBalance(for: transaction, isAdding: false)
            
            // Reverse budget spending if it was an expense
            if transaction.type == .expense {
                budgetManager?.updateBudgetSpending(for: transaction.category, amount: transaction.amount, isAdding: false)
            }
        }
    }

    private func updateAccountBalance(for transaction: Transaction, isAdding: Bool) {
        if let accountIndex = accounts.firstIndex(where: { $0.id == transaction.account.id }) {
            let multiplier: Double = isAdding ? 1.0 : -1.0

            switch transaction.type {
            case .income:
                accounts[accountIndex].balance += (transaction.amount * multiplier)
            case .expense:
                accounts[accountIndex].balance -= (transaction.amount * multiplier)
            case .transfer:
                // Handle transfer logic here if needed
                break
            }
            
            saveAccounts()
        }
    }

    // MARK: - Helper Methods

    func categoriesForType(_ type: TransactionType) -> [TransactionCategory] {
        return categories.filter { $0.type == type }
    }

    func transactionsForDate(_ date: Date) -> [Transaction] {
        return transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func transactionsForAccount(_ account: Account) -> [Transaction] {
        return transactions.filter { $0.account.id == account.id }
    }

    func transactionsForCategory(_ category: TransactionCategory) -> [Transaction] {
        return transactions.filter { $0.category.id == category.id }
    }

    // MARK: - Analytics Methods

    func totalBalance() -> Double {
        return accounts.reduce(0) { $0 + $1.balance }
    }

    func totalIncomeForPeriod(from startDate: Date, to endDate: Date) -> Double {
        return transactions
            .filter { $0.type == .income && $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }

    func totalExpenseForPeriod(from startDate: Date, to endDate: Date) -> Double {
        return transactions
            .filter { $0.type == .expense && $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }
    
    func expensesForCategory(_ category: TransactionCategory, from startDate: Date, to endDate: Date) -> Double {
        return transactions
            .filter {
                $0.category.id == category.id &&
                $0.type == .expense &&
                $0.date >= startDate &&
                $0.date <= endDate
            }
            .reduce(0) { $0 + $1.amount }
    }
}
