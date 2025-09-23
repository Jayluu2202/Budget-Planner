//
//  AccountsView.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct AccountsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var accountStore = AccountStore()
    @State private var navigateToAdd = false
    
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
                            
                            Text("Accounts")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    
                    NavigationLink(destination: AddAccountView(accountStore: accountStore), isActive: $navigateToAdd) {
                        Button(action: {
                            navigateToAdd = true
                        }) {
                            Text("Add")
                                .font(.system(size: 17, weight: .medium))
                                .frame(width: 50, height: 30)
                                .foregroundColor(.white)
                                .background(Color.black)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Accounts List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(accountStore.accounts) { account in
                            // Make AccountRow tappable with NavigationLink
                            NavigationLink(
                                destination: EditAccountView(account: account, accountStore: accountStore)
                                    .navigationBarHidden(true)
                            ) {
                                AccountRow(account: account, accountStore: accountStore)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .background(Color(.white))
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

struct AccountRow: View {
    let account: Account
    let accountStore: AccountStore
    
    var body: some View {
        HStack {
            // Icon
            Text(account.emoji)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Account Info
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
                
                Text(AccountStore().formatBalance(balance: account.balance))
                    .font(.system(size: 15))
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
    }
}
