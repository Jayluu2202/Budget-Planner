//
//  AccountModel.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import Foundation

struct Account: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var balance: Double
    
    // when we want to create an account
    init(name: String, emoji: String, balance: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.balance = balance
    }
    
    // when we want to update an account
    init(id: UUID, name: String, emoji: String, balance: Double) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.balance = balance
    }
}
