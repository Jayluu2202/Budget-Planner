//
//  TransactionModel.swift
//  Budget Planner
//
//  Fixed version with consistent property names and initializers
//

import Foundation

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    let id: UUID
    var type: TransactionType
    var amount: Double
    var description: String
    var date: Date
    var account: Account
    var category: TransactionCategory
    var isRecurring: Bool
    
    //create
    init(type: TransactionType, amount: Double, description: String, date: Date, account: Account, category: TransactionCategory, isRecurring: Bool = false) {
        self.id = UUID()
        self.type = type
        self.amount = amount
        self.description = description
        self.date = date
        self.account = account
        self.category = category
        self.isRecurring = isRecurring
    }
    
    ///update
    // Additional initializer with id parameter for when loading from storage
    init(id: UUID, type: TransactionType, amount: Double, description: String, date: Date, account: Account, category: TransactionCategory, isRecurring: Bool = false) {
        self.id = id
        self.type = type
        self.amount = amount
        self.description = description
        self.date = date
        self.account = account
        self.category = category
        self.isRecurring = isRecurring
    }
}

// MARK: - Transaction Type
enum TransactionType: String, CaseIterable, Codable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"
    
    var color: String {
        switch self {
        case .income: return "green"
        case .expense: return "red"
        case .transfer: return "blue"
        }
    }
}
