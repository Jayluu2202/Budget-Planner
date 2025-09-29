//
//  budgetViewTab.swift
//  Budget Planner
//
//  FIXED VERSION: Use shared CurrencyManager from environment
//

import SwiftUI

struct budgetViewTab: View {
    @StateObject var budgetManager = BudgetManager()
    @StateObject var transactionManager = TransactionManager()
    // CHANGE: Use EnvironmentObject instead of StateObject
    @ObservedObject var currencyManager = CurrencyManager()
    @State private var showAddBudget = false
    
    var transportTotal: Double {
        var sum = 0.0
        for cat in transactionManager.transactions {
            if cat.category.name == "Transport" {
                print(cat.amount)
                sum += cat.amount
            }
        }
        return sum
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Custom header since we're hiding the navigation bar
                    VStack(spacing: 0) {
                        Text("Budget Overview")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 65)
                        
                        Divider()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                            .padding(.bottom)
                    }
                    .background(Color(.systemBackground))
                    
                    // Budgets List
                    buildBudgetsList()
                }
                .ignoresSafeArea()
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddBudget = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(.systemBackground))
                                .padding()
                                .background(Color.primary)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddBudget) {
                AddBudgetView(
                    budgetManager: budgetManager
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            setupManagerLinking()
            loadAndSyncData()
        }
        .onChange(of: showAddBudget) { isShowing in
            if !isShowing {
                syncAllBudgetsWithTransactions()
            }
        }
        .onReceive(transactionManager.$transactions) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                syncAllBudgetsWithTransactions()
            }
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupManagerLinking() {
        // CRITICAL: Link managers properly
//        transactionManager.setBudgetManager(budgetManager)
//        print("🔗 Managers linked successfully")
    }
    
    private func loadAndSyncData() {
        budgetManager.loadData()
        transactionManager.loadData()
        
        // Always sync budgets with transactions when view appears
        syncAllBudgetsWithTransactions()
//        print("📂 Data loaded and synced")
    }
    
    private func syncAllBudgetsWithTransactions() {
        budgetManager.syncAllBudgetsWithTransactions(transactionManager.transactions)
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildBudgetsList() -> some View {
        let filteredBudgets = getFilteredBudgets()
        
        if filteredBudgets.isEmpty {
            buildEmptyState()
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredBudgets) { budget in
                        NavigationLink(
                            destination: BudgetDetailsView(
                                budget: budget,
                                budgetManager: budgetManager,
                                transactionManager: transactionManager
                            )
                        ) {
                            BudgetCard(
                                budget: budget,
                                transactions: transactionManager.transactions,
                                currencyManager: currencyManager, // CHANGE: Pass currencyManager
                                onDelete: {
                                    deleteBudget(budget)
                                }, transactionManager: transactionManager
                            )
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Budgets")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Create budgets to track your spending and stay on top of your finances")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Create Budget") {
                showAddBudget = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func getFilteredBudgets() -> [Budget] {
        return budgetManager.activeBudgets().sorted { $0.daysPassed > $1.daysPassed }
    }
    
    private func deleteBudget(_ budget: Budget) {
        withAnimation(.easeOut(duration: 0.3)) {
            budgetManager.deleteBudget(budget)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        if let formattedNumber = formatter.string(from: NSNumber(value: abs(amount))) {
            return formattedNumber
        }
        return "\(Int(abs(amount)))"
    }
}

// MARK: - Budget Card Component (UPDATED)
struct BudgetCard: View {
    let budget: Budget
    let transactions: [Transaction]
    let currencyManager: CurrencyManager // CHANGE: Add currencyManager parameter
    let onDelete: () -> Void
    @ObservedObject var transactionManager: TransactionManager
    @State private var selectedMonth = Date()
    
    // Calculate spending just for this budget
//    private var spentForThisBudget: Double {
//        transactions
//            .filter { $0.category.name == budget.category.name }
//            .reduce(0) { $0 + $1.amount }
//    }
    
    private var sspentForThisBudget: Double {
        let calendar = Calendar.current
        return transactionManager.transactions
            .filter { transaction in
                // Filter by category name, type, and selected month/year
                return transaction.category.name == budget.category.name &&
                transaction.type == .expense &&
                calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month) &&
                calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .year)
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var remainingAmount: Double {
        budget.budgetAmount - sspentForThisBudget
    }
    
    private var progressPercentage: Double {
        guard budget.budgetAmount > 0 else { return 0 }
        return (sspentForThisBudget / budget.budgetAmount) * 100
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with category and amount
            HStack {
                HStack(spacing: 12) {
                    Text(budget.category.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.category.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if !budget.description.isEmpty &&
                            budget.description != "Budget for \(budget.category.name)" {
                            Text(budget.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // CHANGE: Use currencyManager.selectedCurrency.symbol
                    Text("\(currencyManager.selectedCurrency.symbol)\(formatAmount(remainingAmount))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(currencyManager.selectedCurrency.symbol)\(String(format: "%.2f", sspentForThisBudget)) / \(currencyManager.selectedCurrency.symbol)\(String(format: "%.2f", budget.budgetAmount))")
                        .font(.caption)
                }
            }
            
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(.primary)
                            .frame(
                                width: min(
                                    geometry.size.width * CGFloat(progressPercentage / 100),
                                    geometry.size.width
                                ),
                                height: 8
                            )
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text(daysRemainingText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Days remaining (same as before)
    private var daysRemainingText: String {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let totalDays = range.count
        let day = calendar.component(.day, from: today)
        let remaining = max(0, totalDays - day)
        return "\(remaining) days remaining"
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "\(Int(abs(amount)))"
    }
}

// MARK: - Preview
struct budgetViewTab_Previews: PreviewProvider {
    static var previews: some View {
        budgetViewTab()
            .environmentObject(CurrencyManager()) // CHANGE: Add environment object
    }
}
