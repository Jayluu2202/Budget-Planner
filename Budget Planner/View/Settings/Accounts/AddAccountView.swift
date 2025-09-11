//
//  AddAccountView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var accountStore: AccountStore
    
    @State private var accountName = ""
    @State private var initialBalance = ""
    @State private var selectedEmoji = "💰"
    
    private let availableEmojis = ["💰", "💳", "🏛️", "💵", "🏦", "💎", "💹", "💸", "📊"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                            
                            Text("Add Account")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                VStack(spacing: 20) {
                    // Account Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Account Name", text: $accountName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Initial Balance Input
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Initial Balance", text: $initialBalance)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Emoji Selection
                    VStack(alignment: .leading, spacing: 12) {
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                ForEach(availableEmojis, id: \.self) { emoji in
                                    Button(action: {
                                        selectedEmoji = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 24))
                                            .frame(width: 50, height: 50)
                                            .background(selectedEmoji == emoji ? Color.black.opacity(0.1) : Color.clear)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedEmoji == emoji ? Color.black : Color.gray, lineWidth: selectedEmoji == emoji ? 2 : 1.5)
                                            )
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    
                    // Add Button
                    Button(action: addAccount) {
                        Text("Add Account")
                            .font(.system(size: 17, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(accountName.isEmpty ? Color.gray : Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(accountName.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Existing Accounts List
                if !accountStore.accounts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(accountStore.accounts) { account in
                            HStack {
                                Text(account.emoji)
                                    .font(.system(size: 20))
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                
                                Text(account.name)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Spacer()
                                
                                Text(accountStore.formatBalance(balance: account.balance))
                                    .font(.system(size: 15))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    private func addAccount() {
        let balance = Double(initialBalance) ?? 0.0
        let newAccount = Account(name: accountName, emoji: selectedEmoji, balance: balance)
        accountStore.addAccount(account: newAccount)
        dismiss()
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView(accountStore: AccountStore())
    }
}
