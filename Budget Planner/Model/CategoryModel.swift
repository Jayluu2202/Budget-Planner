//
//  CategoryModel.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: UUID
    let name: String
    let emoji: String
    let type: CategoryType
    
    init(name: String, emoji: String, type: CategoryType) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.type = type
    }
    
    init(id: UUID, name: String, emoji: String, type: CategoryType) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.type = type
    }
    
    enum CategoryType: String, CaseIterable, Codable {
        case income = "Income"
        case expense = "Expense"
    }
}
