//
//  MyWealth.swift
//  Budget Planner
//
//  Created by mac on 10/09/25.
//

import SwiftUI

struct MyWealth: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var accountStore = AccountStore()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 20) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("Wealth Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
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
                            .foregroundColor(.gray)
                            .tracking(0.5)
                        
                        Text("₹\(formattedTotalBalance)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Check Future Wealth Button
                    Button(action: {
                        // Add your future wealth navigation logic here
                        print("Check Future Wealth tapped")
                    }) {
                        HStack(spacing: 12) {
                            Text("🔮")
                                .font(.system(size: 20))
                            
                            Text("Check Future Wealth")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Account Balances Section
                    if !accountStore.accounts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account Balances")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
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
                                backgroundColor: Color.white
                            )
                            
                            AccountSummaryCard(
                                number: negativeAccountsCount,
                                title: "Negative Accounts",
                                backgroundColor: Color.white
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Accounts Yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Add your first account to start tracking your wealth")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .padding(.horizontal, 40)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
        .onAppear {
            accountStore.loadAccounts()
        }
    }
    
    // MARK: - Computed Properties (Now using dynamic data)
    
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

// MARK: - Supporting Views

struct AccountBalanceRow: View {
    let account: Account
    
    var body: some View {
        HStack(spacing: 16) {
            // Account Icon
            Text(account.emoji)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Account Name
            Text(account.name)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            // Balance (Color changes based on positive/negative)
            Text("₹\(formattedBalance)")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(account.balance >= 0 ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
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
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct MyWealth_Previews: PreviewProvider {
    static var previews: some View {
        MyWealth()
    }
}
