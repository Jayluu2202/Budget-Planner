//
//  EditAccountView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI

struct EditAccountView: View {
    @Environment(\.dismiss) var dismiss
    let account: Account
    @ObservedObject var accountStore: AccountStore
    
    @State private var accountName: String
    @State private var accountBalance: String
    @State private var selectedEmoji: String
    @State private var showingDeleteAlert = false
    
    private let availableEmojis = ["💰", "💳", "🏛️", "💵", "🏦", "💎", "💹", "💸", "📊"]
    
    init(account: Account, accountStore: AccountStore) {
        self.account = account
        self.accountStore = accountStore
        self._accountName = State(initialValue: account.name)
        self._accountBalance = State(initialValue: String(Int(account.balance)))
        self._selectedEmoji = State(initialValue: account.emoji)
    }
    
    var body: some View {
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
                        
                        Text("Edit Account")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.red)
                }
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
                
                // Account Balance Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Account Balance", text: $accountBalance)
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
                
                // Save Button
                Button(action: saveAccount) {
                    Text("Save")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(accountName.isEmpty ? Color.gray : Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(accountName.isEmpty)
                .padding(.horizontal)
//                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .background(Color(.systemGray6))
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this account? This action cannot be undone.")
        }
    }
    
    private func saveAccount() {
        let balance = Double(accountBalance) ?? account.balance
        let updatedAccount = Account(
            id: account.id,
            name: accountName,
            emoji: selectedEmoji,
            balance: balance
        )
        accountStore.updateAccount(account: updatedAccount)
        dismiss()
    }
    
    private func deleteAccount() {
        accountStore.deleteAccount(account: account)
        dismiss()
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountView(
            account: Account(name: "Sample Account", emoji: "💰", balance: 1000),
            accountStore: AccountStore()
        )
    }
}
