//
//  BudgetModel.swift
//  Budget Planner
//

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

    var monthYear: String // Track which month/year this budget belongs to
    
    // ADD THESE NEW PROPERTIES:
    var month: Int // 1-12
    var year: Int // 2024, 2025, etc.

    
    init(category: TransactionCategory, budgetAmount: Double, description: String = "", startDate: Date = Date(), endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()) {
        self.id = UUID()
        self.category = category
        self.budgetAmount = budgetAmount
        self.spentAmount = 0.0
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true

        
        // Set month/year identifier for automatic reset
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-yyyy"
        self.monthYear = formatter.string(from: startDate)
        
        // ADD THESE LINES:
        let calendar = Calendar.current
        self.month = calendar.component(.month, from: startDate)
        self.year = calendar.component(.year, from: startDate)
    }
    
    init(id: UUID, category: TransactionCategory, budgetAmount: Double, spentAmount: Double, description: String, startDate: Date, endDate: Date, isActive: Bool, monthYear: String? = nil, month: Int? = nil, year: Int? = nil) {
        self.id = id
        self.category = category
        self.budgetAmount = budgetAmount
        self.spentAmount = spentAmount
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive

        
        // Set month/year if not provided
        if let monthYear = monthYear {
            self.monthYear = monthYear
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-yyyy"
            self.monthYear = formatter.string(from: startDate)
        }
        
        // ADD THESE LINES:
        let calendar = Calendar.current
        if let month = month, let year = year {
            self.month = month
            self.year = year
        } else {
            self.month = calendar.component(.month, from: startDate)
            self.year = calendar.component(.year, from: startDate)
        }

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
    
    // Changed from daysRemaining to daysPassed in current month
    var daysPassed: Int {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the start of current month
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        
        // Calculate days passed from start of month to today
        let daysPassed = calendar.dateComponents([.day], from: startOfMonth, to: today).day ?? 0
        return max(daysPassed, 0)
    }
    
    // Total days in current month
    var totalDaysInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)
        return range?.count ?? 30
    }
    
    // Check if budget needs to be reset (new month)
    var needsMonthlyReset: Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        return month != currentMonth || year != currentYear
    }
    
    var budgetStatus: BudgetStatus {
        let percentage = progressPercentage
        
        if isOverBudget {
            return .overBudget
        } else if percentage >= 80 {
            return .warning

        } else {
            return .onTrack
        }
    }
}

// MARK: - Budget Status Enum (Updated without 'safe')
enum BudgetStatus {
    case onTrack    // < 80%

    case warning    // 80-100%
    case overBudget // > 100%
    
    var color: String {
        switch self {
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
        case .onTrack:
            return "On Track"
        case .warning:
            return "Warning"
        case .overBudget:
            return "Over Budget"
        }
    }
}
