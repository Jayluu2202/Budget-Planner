//  TransactionCategoryModel.swift
//  Budget Planner
//
//  Created by mac on 10/09/25.
//

import Foundation

// MARK: - Transaction Category Model
struct TransactionCategory: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var type: TransactionType
    
    init(name: String, emoji: String, type: TransactionType) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.type = type
    }
    
    init(id: UUID, name: String, emoji: String, type: TransactionType) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.type = type
    }
}
