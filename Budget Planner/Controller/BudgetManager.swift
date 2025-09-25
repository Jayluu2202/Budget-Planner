//
//  BudgetManager.swift
//  Budget Planner
//
//  Fixed version with proper monthly budget isolation
//

import Foundation
import SwiftUI

// MARK: - Budget Manager
class BudgetManager: ObservableObject {
    @Published var budgets: [Budget] = []
    
    private let budgetsKey = "budgets_key"
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadBudgets()
        checkAndResetMonthlyBudgets()
    }
    
    // MARK: - Data Persistence
    
    func loadData() {
        loadBudgets()
        checkAndResetMonthlyBudgets()
    }
    
    private func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            userDefaults.set(encoded, forKey: budgetsKey)
        }
    }
    
    private func loadBudgets() {
        if let data = userDefaults.data(forKey: budgetsKey),
           let decodedBudgets = try? JSONDecoder().decode([Budget].self, from: data) {
            self.budgets = decodedBudgets
        }
    }
    
    // MARK: - Monthly Reset Logic (IMPROVED)
    
    func checkAndResetMonthlyBudgets() {
        var hasChanges = false
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        for index in budgets.indices {
            // Check if budget needs monthly reset
            if budgets[index].month != currentMonth || budgets[index].year != currentYear {
                if budgets[index].isActive {
                    // Reset the budget for new month
                    let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
                    let endOfMonth = calendar.dateInterval(of: .month, for: today)?.end ?? calendar.date(byAdding: .month, value: 1, to: today) ?? today
                    
                    // Update month/year identifier
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM-yyyy"
                    let newMonthYear = formatter.string(from: today)
                    
                    // Reset spent amount and update dates and month/year
                    budgets[index].spentAmount = 0.0
                    budgets[index].startDate = startOfMonth
                    budgets[index].endDate = endOfMonth
                    budgets[index].monthYear = newMonthYear
                    budgets[index].month = currentMonth
                    budgets[index].year = currentYear
                    
                    hasChanges = true
                    print("✅ Reset budget for \(budgets[index].category.name) for month: \(newMonthYear)")
                }
            }
        }
        
        if hasChanges {
            saveBudgets()
        }
    }
    
    // MARK: - Budget Management
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
    }
    
    func addBudget(_ budget: Budget, syncWithTransactions transactions: [Transaction]) {
        budgets.append(budget)
        
        syncBudgetWithTransactions(budgetId: budget.id, transactions: transactions)
        
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    func deleteBudget(at indexSet: IndexSet) {
        budgets.remove(atOffsets: indexSet)
        saveBudgets()
    }
    
    // MARK: - Transaction Synchronization (FIXED FOR MONTHLY ISOLATION)
    
    // Sync a specific budget with existing transactions FOR ITS SPECIFIC MONTH/YEAR ONLY
    func syncBudgetWithTransactions(budgetId: UUID, transactions: [Transaction]) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budgetId }) else {
            print("⚠️ Budget not found for sync: \(budgetId)")
            return
        }
        
        let budget = budgets[budgetIndex]
        let calendar = Calendar.current
        
        // Calculate total spending for this category within the budget's specific month/year
        let totalSpent = transactions
            .filter { transaction in
                let transactionMonth = calendar.component(.month, from: transaction.date)
                let transactionYear = calendar.component(.year, from: transaction.date)
                
                return transaction.category.id == budget.category.id &&
                transaction.type == .expense &&
                transactionMonth == budget.month &&
                transactionYear == budget.year
            }
            .reduce(0) { $0 + $1.amount }
        
        // Update budget spent amount
        budgets[budgetIndex].spentAmount = totalSpent
        print("📊 Synced budget \(budget.category.name) for \(budget.month)/\(budget.year): spent = \(totalSpent)")
        
        // Force UI update
        objectWillChange.send()
    }
    
    // Sync all budgets with transactions (FIXED FOR MONTHLY ISOLATION)
    func syncAllBudgetsWithTransactions(_ transactions: [Transaction]) {
        var hasChanges = false
        let calendar = Calendar.current
        
        for index in budgets.indices {
            if budgets[index].isActive {
                let budget = budgets[index]
                
                // Calculate actual spending for this category in the budget's specific month/year
                let totalSpent = transactions
                    .filter { transaction in
                        let transactionMonth = calendar.component(.month, from: transaction.date)
                        let transactionYear = calendar.component(.year, from: transaction.date)
                        
                        return transaction.category.id == budget.category.id &&
                        transaction.type == .expense &&
                        transactionMonth == budget.month &&
                        transactionYear == budget.year
                    }
                    .reduce(0) { $0 + $1.amount }
                
                // Only update if there's a difference
                if budgets[index].spentAmount != totalSpent {
                    budgets[index].spentAmount = totalSpent
                    hasChanges = true
                    print("📊 Updated budget \(budget.category.name) for \(budget.month)/\(budget.year): spent = \(totalSpent)")
                }
            }
        }
        
        if hasChanges {
            objectWillChange.send()
            saveBudgets()
        }
    }
    
    // MARK: - Budget Updates from Transactions (FIXED FOR MONTHLY ISOLATION)
    
    func updateBudgetSpending(for category: TransactionCategory, amount: Double, isAdding: Bool = true) {
        let multiplier: Double = isAdding ? 1.0 : -1.0
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        // First check for monthly resets
        checkAndResetMonthlyBudgets()
        
        var budgetUpdated = false
        
        for index in budgets.indices {
            // FIXED: Only update budget if it's for the current month/year and same category
            if budgets[index].category.id == category.id &&
               budgets[index].isActive &&
               budgets[index].month == currentMonth &&
               budgets[index].year == currentYear {
                
                let oldAmount = budgets[index].spentAmount
                budgets[index].spentAmount += (amount * multiplier)
                // Ensure spent amount doesn't go negative
                budgets[index].spentAmount = max(0, budgets[index].spentAmount)
                
                budgetUpdated = true
                print("💰 Updated budget spending for \(category.name) in \(currentMonth)/\(currentYear): \(oldAmount) -> \(budgets[index].spentAmount)")
                break
            }
        }
        
        if budgetUpdated {
            // Force UI update
            objectWillChange.send()
            saveBudgets()
            print("✅ Budget spending updated and saved")
        } else {
            print("⚠️ No active budget found for category: \(category.name) in month \(currentMonth)/\(currentYear)")
        }
    }
    
    // MARK: - Helper Methods (UPDATED)
    
    func activeBudgets() -> [Budget] {
        // Check for monthly resets first
        checkAndResetMonthlyBudgets()
        
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        return budgets.filter { budget in
            budget.isActive &&
            budget.month == currentMonth &&
            budget.year == currentYear
        }
    }
    
    func expiredBudgets() -> [Budget] {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        return budgets.filter { budget in
            (budget.year < currentYear) ||
            (budget.year == currentYear && budget.month < currentMonth)
        }
    }
    
    func budgetForCategory(_ category: TransactionCategory) -> Budget? {
        checkAndResetMonthlyBudgets()
        
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        return budgets.first { budget in
            budget.category.id == category.id &&
            budget.isActive &&
            budget.month == currentMonth &&
            budget.year == currentYear
        }
    }
    
    // MARK: - Month-specific budget retrieval methods (NEW)
    
    func budgetForCategory(_ category: TransactionCategory, month: Int, year: Int) -> Budget? {
        return budgets.first { budget in
            budget.category.id == category.id &&
            budget.isActive &&
            budget.month == month &&
            budget.year == year
        }
    }
    
    func budgetsForMonth(_ month: Int, year: Int) -> [Budget] {
        return budgets.filter { budget in
            budget.month == month && budget.year == year && budget.isActive
        }
    }
    
    // MARK: - Analytics (Updated to work with current month)
    
    func totalBudgetAmount() -> Double {
        return activeBudgets().reduce(0) { $0 + $1.budgetAmount }
    }
    
    func totalSpentAmount() -> Double {
        return activeBudgets().reduce(0) { $0 + $1.spentAmount }
    }
    
    func totalRemainingAmount() -> Double {
        return activeBudgets().reduce(0) { $0 + $1.remainingAmount }
    }
    
    func budgetsNeedingAttention() -> [Budget] {
        return activeBudgets().filter { budget in
            budget.budgetStatus == .warning || budget.budgetStatus == .overBudget
        }
    }
    
    func budgetPerformanceData() -> (onTrack: Int, warning: Int, overBudget: Int) {
        let active = activeBudgets()
        let onTrack = active.filter { $0.budgetStatus == .onTrack }.count
        let warning = active.filter { $0.budgetStatus == .warning }.count
        let overBudget = active.filter { $0.budgetStatus == .overBudget }.count
        
        return (onTrack: onTrack, warning: warning, overBudget: overBudget)
    }
}
