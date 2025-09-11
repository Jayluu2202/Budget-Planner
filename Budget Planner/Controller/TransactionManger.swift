//
//  TransactionManager.swift
//  Budget Planner
//
//  Fixed version with proper account balance synchronization
//

import Foundation
import SwiftUI

// MARK: - Transaction Manager
class TransactionManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var accounts: [Account] = []
    @Published var categories: [TransactionCategory] = []
    
    // Shared AccountStore reference to maintain data consistency
    private let accountStore = AccountStore.shared

    private let transactionsKey = "transactions_key"
    private let accountsKey = "accounts_key"
    private let categoriesKey = "categories_key"

    init() {
        loadData()
    }

    // MARK: - Data Persistence

    func loadData() {
        loadTransactions()
        loadAccounts()
        loadCategories()
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
    }

    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            let oldTransaction = transactions[index]

            // Reverse old transaction balance effect
            updateAccountBalance(for: oldTransaction, isAdding: false)

            // Update transaction
            transactions[index] = transaction
            saveTransactions()

            // Apply new transaction balance effect
            updateAccountBalance(for: transaction, isAdding: true)
        }
    }

    func deleteTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions.remove(at: index)
            saveTransactions()

            // Reverse the balance change
            updateAccountBalance(for: transaction, isAdding: false)
        }
    }

    // FIXED: Proper account balance update with persistent storage
    private func updateAccountBalance(for transaction: Transaction, isAdding: Bool) {
        // Load latest accounts from AccountStore
        accountStore.loadAccounts()
        
        if let accountIndex = accountStore.accounts.firstIndex(where: { $0.id == transaction.account.id }) {
            let multiplier: Double = isAdding ? 1.0 : -1.0

            switch transaction.type {
            case .income:
                accountStore.accounts[accountIndex].balance += (transaction.amount * multiplier)
            case .expense:
                accountStore.accounts[accountIndex].balance -= (transaction.amount * multiplier)
            case .transfer:
                // Handle transfer logic here if needed
                break
            }

            // Save the updated account
            accountStore.saveAccounts()
            
            // Also update our local accounts array for consistency
            if let localIndex = accounts.firstIndex(where: { $0.id == transaction.account.id }) {
                accounts[localIndex] = accountStore.accounts[accountIndex]
            }
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
}
