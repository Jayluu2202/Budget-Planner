//
//  OnboardingView.swift
//  Budget Planner
//
//  Created by mac on 22/09/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var accountStore = AccountStore()
    @StateObject private var categoryStore = CategoryStore()
    @StateObject private var currencyManager = CurrencyManager()
    @ObservedObject var onboardingManager: OnboardingManager
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            // Progress Indicator
            HStack {
                ForEach(0..<3) { index in
                    Rectangle()
                        .frame(height: 4)
                        .foregroundColor(index <= currentPage ? .black : .gray.opacity(0.3))
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            // Page Content
            TabView(selection: $currentPage) {
                // Page 1: Welcome & Currency
                OnboardingCurrencyPage(currencyManager: currencyManager, currentPage: $currentPage)
                    .tag(0)
                
                // Page 2: Add Accounts
                OnboardingAccountsPage(accountStore: accountStore, currentPage: $currentPage)
                    .tag(1)
                
                // Page 3: Add Categories
                OnboardingCategoriesPage(categoryStore: categoryStore, onboardingManager: onboardingManager)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Currency Setup Page
struct OnboardingCurrencyPage: View {
    @ObservedObject var currencyManager: CurrencyManager
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.black)
                
                Text("Welcome to Budget Planner!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("First, let's set up your currency")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            // Current Currency Selection
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Selected Currency")
                            .font(.headline)
                        Text(currencyManager.selectedCurrency.code + " - " + currencyManager.selectedCurrency.name)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(currencyManager.selectedCurrency.symbol)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                NavigationLink(destination: CurrencyChangeView(currencyManager: currencyManager)) {
                    Text("Change Currency")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.black)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            Button(action: {
                currentPage = 1
            }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Accounts Setup Page
struct OnboardingAccountsPage: View {
    @ObservedObject var accountStore: AccountStore
    @Binding var currentPage: Int
    @State private var showAddAccount = false
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.black)
                
                Text("Add Your Accounts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Set up your income sources like salary, freelance, etc.")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            // Accounts List or Empty State
            if accountStore.accounts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No accounts added yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(accountStore.accounts) { account in
                            HStack {
                                Text(account.emoji)
                                    .font(.system(size: 24))
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(account.name)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Text(accountStore.formatBalance(balance: account.balance))
                                        .font(.system(size: 15))
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
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
                }
                .frame(maxHeight: 200)
            }
            
            Button(action: {
                showAddAccount = true
            }) {
                Text("Add Account")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.black)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    currentPage = 2
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                
                if !accountStore.accounts.isEmpty {
                    Text("You can always add more accounts later")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showAddAccount) {
            AddAccountView(accountStore: accountStore)
        }
    }
}

// MARK: - Categories Setup Page
struct OnboardingCategoriesPage: View {
    @ObservedObject var categoryStore: CategoryStore
    @ObservedObject var onboardingManager: OnboardingManager
    @State private var showAddCategory = false
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.black)
                
                Text("Add Categories")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Create expense categories to organize your spending")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            // Categories List or Empty State
            let expenseCategories = categoryStore.getCategories(for: .expense)
            
            if expenseCategories.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No categories added yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                        ForEach(expenseCategories) { category in
                            VStack(spacing: 8) {
                                Text(category.emoji)
                                    .font(.system(size: 24))
                                Text(category.name)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            Button(action: {
                showAddCategory = true
            }) {
                Text("Add Category")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.black)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    onboardingManager.completeOnboarding()
                }) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                
                Text("You can always add more categories later")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showAddCategory) {
            AddCategoriesView(isPresented: $showAddCategory)
                .environmentObject(categoryStore)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView(onboardingManager: OnboardingManager())
        }
    }
}
