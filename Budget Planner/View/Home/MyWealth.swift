//
//  MyWealth.swift
//  Budget Planner
//
//  Updated with proper dark mode color support
//

import SwiftUI
import UIKit

struct MyWealth: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var accountStore = AccountStore()
    let actualCurrency = CurrencyManager().selectedCurrency.symbol
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 20) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Wealth Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Current Total Balance Card
                    VStack(spacing: 12) {
                        Text("CURRENT TOTAL BALANCE")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .tracking(0.5)
                        
                        Text("\(actualCurrency)\(formattedTotalBalance)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Check Future Wealth Button
                    Button(action: {
                        print("Check Future Wealth tapped")
                    }) {
                        HStack(spacing: 12) {
                            Text("🔮")
                                .font(.system(size: 20))
                            
                            Text("Check Future Wealth")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(.systemBackground))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.label))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Account Balances Section
                    if !accountStore.accounts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account Balances")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(accountStore.accounts) { account in
                                    AccountBalanceRow(account: account)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Account Summary Cards
                        HStack(spacing: 16) {
                            AccountSummaryCard(
                                number: positiveAccountsCount,
                                title: "Positive Accounts",
                                backgroundColor: Color(.systemBackground)
                            )
                            
                            AccountSummaryCard(
                                number: negativeAccountsCount,
                                title: "Negative Accounts",
                                backgroundColor: Color(.systemBackground)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No Accounts Yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Add your first account to start tracking your wealth")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .padding(.horizontal, 40)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            accountStore.loadAccounts()
            // SOLUTION 2: Fallback for older iOS versions
            hideTabBarLegacy()
        }
        .onDisappear {
            showTabBarLegacy()
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalBalance: Double {
        accountStore.accounts.reduce(0) { $0 + $1.balance }
    }
    
    private var formattedTotalBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "0"
    }
    
    private var positiveAccountsCount: Int {
        accountStore.accounts.filter { $0.balance > 0 }.count
    }
    
    private var negativeAccountsCount: Int {
        accountStore.accounts.filter { $0.balance < 0 }.count
    }
}

// MARK: - Tab Bar Helper Methods

extension MyWealth {
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

// MARK: - Supporting Views

struct AccountBalanceRow: View {
    let account: Account
    
    var body: some View {
        HStack(spacing: 16) {
            Text(account.emoji)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(account.name)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            let actualCurrency = CurrencyManager().selectedCurrency.symbol
            
            Text("\(actualCurrency)\(formattedBalance)")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(account.balance >= 0 ? Color(.systemGreen) : Color(.systemRed))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
    
    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: abs(account.balance))) ?? "0"
    }
}

struct AccountSummaryCard: View {
    let number: Int
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

struct MyWealth_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MyWealth()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            MyWealth()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
