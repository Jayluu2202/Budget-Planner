//
//  BudgetManager.swift
//  Budget Planner
//
//  Created by Assistant on 11/09/25.
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
    }
    
    // MARK: - Data Persistence
    
    func loadData() {
        loadBudgets()
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
    
    // MARK: - Budget Management
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
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
    
    // MARK: - Budget Updates from Transactions
    
    func updateBudgetSpending(for category: TransactionCategory, amount: Double, isAdding: Bool = true) {
        let multiplier: Double = isAdding ? 1.0 : -1.0
        
        for index in budgets.indices {
            if budgets[index].category.id == category.id && budgets[index].isActive {
                let currentDate = Date()
                
                // Check if the budget period is still active
                if currentDate >= budgets[index].startDate && currentDate <= budgets[index].endDate {
                    budgets[index].spentAmount += (amount * multiplier)
                    // Ensure spent amount doesn't go negative
                    budgets[index].spentAmount = max(0, budgets[index].spentAmount)
                    saveBudgets()
                    break
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func activeBudgets() -> [Budget] {
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
        let onTrack = active.filter { $0.budgetStatus == .safe || $0.budgetStatus == .onTrack }.count
        let warning = active.filter { $0.budgetStatus == .warning }.count
        let overBudget = active.filter { $0.budgetStatus == .overBudget }.count
        
        return (onTrack: onTrack, warning: warning, overBudget: overBudget)
    }
}
