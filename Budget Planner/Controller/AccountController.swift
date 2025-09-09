//
//  AccountController.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import Foundation

class AccountStore: ObservableObject {
    @Published var accounts: [Account] = []
    private let userDefaults = UserDefaults.standard
    private let accountsKey = "SavedAccounts"
    
    init() {
        loadAccounts()
        // Add default accounts if none exist
        if accounts.isEmpty {
            addDefaultAccounts()
        }
    }
    
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
    }
    
    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            userDefaults.set(encoded, forKey: accountsKey)
        }
    }
    
    private func loadAccounts() {
        if let data = userDefaults.data(forKey: accountsKey),
           let decodedAccounts = try? JSONDecoder().decode([Account].self, from: data) {
            self.accounts = decodedAccounts
        }
    }
    
    private func addDefaultAccounts() {
        let defaultAccounts = [
            Account(name: "Cash", emoji: "🏛️", balance: 19000),
            Account(name: "Credit Card", emoji: "🏛️", balance: 50000),
            Account(name: "Debit Card", emoji: "💳", balance: 12000)
        ]
        accounts = defaultAccounts
        saveAccounts()
    }
    
    func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        if let formattedNumber = formatter.string(from: NSNumber(value: balance)) {
            return "₹\(formattedNumber)"
        }
        return "₹\(Int(balance))"
    }
}
