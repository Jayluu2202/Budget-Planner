//
//  BudgetModel.swift
//  Budget Planner
//
//  Created by Assistant on 11/09/25.
//

import Foundation

// MARK: - Budget Model
struct Budget: Identifiable, Codable {
    let id: UUID
    var category: TransactionCategory
    var budgetAmount: Double
    var spentAmount: Double
    var description: String
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    
    init(category: TransactionCategory, budgetAmount: Double, description: String = "", startDate: Date = Date(), endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()) {
        self.id = UUID()
        self.category = category
        self.budgetAmount = budgetAmount
        self.spentAmount = 0.0
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true
    }
    
    init(id: UUID, category: TransactionCategory, budgetAmount: Double, spentAmount: Double, description: String, startDate: Date, endDate: Date, isActive: Bool) {
        self.id = id
        self.category = category
        self.budgetAmount = budgetAmount
        self.spentAmount = spentAmount
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }
    
    // MARK: - Computed Properties
    
    var remainingAmount: Double {
        return budgetAmount - spentAmount
    }
    
    var progressPercentage: Double {
        guard budgetAmount > 0 else { return 0 }
        return min((spentAmount / budgetAmount) * 100, 100)
    }
    
    var isOverBudget: Bool {
        return spentAmount > budgetAmount
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = Date()
        let days = calendar.dateComponents([.day], from: today, to: endDate).day ?? 0
        return max(days, 0)
    }
    
    var budgetStatus: BudgetStatus {
        let percentage = progressPercentage
        
        if isOverBudget {
            return .overBudget
        } else if percentage >= 80 {
            return .warning
        } else if percentage >= 50 {
            return .onTrack
        } else {
            return .safe
        }
    }
}

// MARK: - Budget Status Enum
enum BudgetStatus {
    case safe       // < 50%
    case onTrack    // 50-80%
    case warning    // 80-100%
    case overBudget // > 100%
    
    var color: String {
        switch self {
        case .safe:
            return "green"
        case .onTrack:
            return "blue"
        case .warning:
            return "orange"
        case .overBudget:
            return "red"
        }
    }
    
    var description: String {
        switch self {
        case .safe:
            return "Safe"
        case .onTrack:
            return "On Track"
        case .warning:
            return "Warning"
        case .overBudget:
            return "Over Budget"
        }
    }
}
