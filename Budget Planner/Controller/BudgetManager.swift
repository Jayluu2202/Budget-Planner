//
//  BudgetManager.swift
//  Budget Planner
//
//  Fixed version with proper transaction synchronization
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
    
    // MARK: - Monthly Reset Logic
    
    func checkAndResetMonthlyBudgets() {
        var hasChanges = false
        
        for index in budgets.indices {
            if budgets[index].needsMonthlyReset && budgets[index].isActive {
                // Reset the budget for new month
                let calendar = Calendar.current
                let today = Date()
                let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
                let endOfMonth = calendar.dateInterval(of: .month, for: today)?.end ?? calendar.date(byAdding: .month, value: 1, to: today) ?? today
                
                // Update month/year identifier
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-yyyy"
                let newMonthYear = formatter.string(from: today)
                
                // Reset spent amount and update dates
                budgets[index].spentAmount = 0.0
                budgets[index].startDate = startOfMonth
                budgets[index].endDate = endOfMonth
                budgets[index].monthYear = newMonthYear
                
                hasChanges = true
                print("Reset budget for \(budgets[index].category.name) for month: \(newMonthYear)")
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
    
    // FIXED: New method to add budget and sync with existing transactions
    func addBudget(_ budget: Budget, syncWithTransactions transactions: [Transaction]) {
        budgets.append(budget)
        
        // Sync with existing transactions for this category
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
    
    // MARK: - Transaction Synchronization (NEW)
    
    // Sync a specific budget with existing transactions
    func syncBudgetWithTransactions(budgetId: UUID, transactions: [Transaction]) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budgetId }) else {
            print("⚠️ Budget not found for sync: \(budgetId)")
            return
        }
        
        let budget = budgets[budgetIndex]
        
        // Calculate total spending for this category within budget period
        let totalSpent = transactions
            .filter { transaction in
                transaction.category.id == budget.category.id &&
                transaction.type == .expense &&
                transaction.date >= budget.startDate &&
                transaction.date <= budget.endDate
            }
            .reduce(0) { $0 + $1.amount }
        
        // Update budget spent amount
        budgets[budgetIndex].spentAmount = totalSpent
        
        print("🔄 Synced budget \(budget.category.name): spent ₹\(totalSpent)")
        
        // Force UI update
        objectWillChange.send()
    }
    
    // Sync all budgets with transactions
    func syncAllBudgetsWithTransactions(_ transactions: [Transaction]) {
        var hasChanges = false
        
        for index in budgets.indices {
            if budgets[index].isActive {
                let budget = budgets[index]
                
                // Calculate actual spending for this category in the budget period
                let totalSpent = transactions
                    .filter { transaction in
                        transaction.category.id == budget.category.id &&
                        transaction.type == .expense &&
                        transaction.date >= budget.startDate &&
                        transaction.date <= budget.endDate
                    }
                    .reduce(0) { $0 + $1.amount }
                
                // Only update if there's a difference
                if budgets[index].spentAmount != totalSpent {
                    budgets[index].spentAmount = totalSpent
                    hasChanges = true
                    print("🔄 Synced budget \(budget.category.name): ₹\(totalSpent)")
                }
            }
        }
        
        if hasChanges {
            objectWillChange.send()
            saveBudgets()
        }
    }
    
    // MARK: - Budget Updates from Transactions (IMPROVED)
    
    func updateBudgetSpending(for category: TransactionCategory, amount: Double, isAdding: Bool = true) {
        print("🎯 Updating budget spending for: \(category.name), amount: ₹\(amount), adding: \(isAdding)")
        
        let multiplier: Double = isAdding ? 1.0 : -1.0
        
        // First check for monthly resets
        checkAndResetMonthlyBudgets()
        
        var budgetUpdated = false
        
        for index in budgets.indices {
            if budgets[index].category.id == category.id && budgets[index].isActive {
                let currentDate = Date()
                
                // Check if the budget period is still active and in current month
                if currentDate >= budgets[index].startDate && currentDate <= budgets[index].endDate {
                    let oldAmount = budgets[index].spentAmount
                    budgets[index].spentAmount += (amount * multiplier)
                    // Ensure spent amount doesn't go negative
                    budgets[index].spentAmount = max(0, budgets[index].spentAmount)
                    
                    print("📈 Budget updated: \(category.name) - Old: ₹\(oldAmount) -> New: ₹\(budgets[index].spentAmount)")
                    
                    budgetUpdated = true
                    break
                }
            }
        }
        
        if budgetUpdated {
            // Force UI update
            objectWillChange.send()
            saveBudgets()
            print("✅ Budget spending updated and saved")
        } else {
            print("⚠️ No active budget found for category: \(category.name)")
        }
    }
    
    // MARK: - Helper Methods
    
    func activeBudgets() -> [Budget] {
        // Check for monthly resets first
        checkAndResetMonthlyBudgets()
        
        let currentDate = Date()
        return budgets.filter { budget in
            budget.isActive && currentDate >= budget.startDate && currentDate <= budget.endDate
        }
    }
    
    func expiredBudgets() -> [Budget] {
        let currentDate = Date()
        return budgets.filter { budget in
            currentDate > budget.endDate
        }
    }
    
    func budgetForCategory(_ category: TransactionCategory) -> Budget? {
        checkAndResetMonthlyBudgets()
        
        let currentDate = Date()
        return budgets.first { budget in
            budget.category.id == category.id &&
            budget.isActive &&
            currentDate >= budget.startDate &&
            currentDate <= budget.endDate
        }
    }
    
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
    
    // MARK: - Analytics
    
    func budgetPerformanceData() -> (onTrack: Int, warning: Int, overBudget: Int) {
        let active = activeBudgets()
        let onTrack = active.filter { $0.budgetStatus == .onTrack }.count
        let warning = active.filter { $0.budgetStatus == .warning }.count
        let overBudget = active.filter { $0.budgetStatus == .overBudget }.count
        
        return (onTrack: onTrack, warning: warning, overBudget: overBudget)
    }
}
