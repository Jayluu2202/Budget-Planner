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
                            .foregroundColor(.primary)
                        
                        Text("Edit Account")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
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
                .background(Color.secondary.opacity(0.3))
            
            VStack(spacing: 20) {
                // Account Name Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Account Name", text: $accountName)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary, lineWidth: 1)
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
                                .stroke(Color.secondary, lineWidth: 1)
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
                                        .background(selectedEmoji == emoji ? Color.primary.opacity(0.1) : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedEmoji == emoji ? Color.primary : Color.secondary, lineWidth: selectedEmoji == emoji ? 2 : 1.5)
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
                        .foregroundColor(Color(.systemBackground))
                        .background(accountName.isEmpty ? Color.secondary : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(accountName.isEmpty)
                .padding(.horizontal)
//                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear{
            hideTabBarLegacy()
        }
        
        .background(Color(.systemBackground))
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

extension EditAccountView {
    // Updated method for hiding tab bar
    private func hideTabBarLegacy() {
        DispatchQueue.main.async {
            // Method 1: Using scene-based approach (iOS 13+)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = true
                } else {
                    // Method 2: Navigate through view hierarchy
                    findAndHideTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    private func showTabBarLegacy() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = false
                } else {
                    findAndShowTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    // Recursive method to find tab bar controller
    private func findAndHideTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = true
        } else if let navigationController = vc as? UINavigationController {
            findAndHideTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndHideTabBar(in: child)
            }
        }
    }
    
    private func findAndShowTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = false
        } else if let navigationController = vc as? UINavigationController {
            findAndShowTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndShowTabBar(in: child)
            }
        }
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
