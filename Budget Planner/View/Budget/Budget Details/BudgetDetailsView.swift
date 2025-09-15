//
//  BudgetDetailsView.swift
//  Budget Planner
//
//  Created by Assistant on 12/09/25.
//

import SwiftUI

struct BudgetDetailsView: View {
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @ObservedObject var transactionManager: TransactionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditBudget = false
    @State private var showDeleteAlert = false
    @State private var selectedMonth = Date()
    
    // Computed properties for budget calculations
    private var dailyBudget: Double {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)
        let totalDaysInMonth = range?.count ?? 30
        let daysPassed = calendar.component(.day, from: today)
        let remainingDays = max(1, totalDaysInMonth - daysPassed + 1)
        
        return budget.remainingAmount / Double(remainingDays)
    }
    
    private var remainingDays: Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)
        let totalDaysInMonth = range?.count ?? 30
        let daysPassed = calendar.component(.day, from: today)
        
        return max(0, totalDaysInMonth - daysPassed)
    }
    
    private var categoryTransactions: [Transaction] {
        return transactionManager.transactions.filter { transaction in
            transaction.category.id == budget.category.id &&
            transaction.type == .expense &&
            transaction.date >= budget.startDate &&
            transaction.date <= budget.endDate
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            buildNavigationBar()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Month Selection
                    buildMonthSelection()
                    
                    // Budget Overview Card
                    buildBudgetOverviewCard()
                    
                    // Action Buttons
                    buildActionButtons()
                    
                    // View Transactions Button
                    buildViewTransactionsButton()
                    
                    // Recent Transactions (if any)
                    if !categoryTransactions.isEmpty {
                        buildRecentTransactions()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditBudget) {
            EditBudgetView(
                budget: budget,
                budgetManager: budgetManager,
                transactionManager: transactionManager
            )
        }
        .alert("Delete Budget", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteBudget()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this budget? This action cannot be undone.")
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildNavigationBar() -> some View {
        HStack(spacing: 12) {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            // Category Icon and Name
            Text(budget.category.emoji)
                .font(.title2)
            
            Text(budget.category.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color(.systemGray6))
    }
    
    @ViewBuilder
    private func buildMonthSelection() -> some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 12) {
                // Previous months (lighter)
                ForEach(getPreviousMonths(), id: \.self) { month in
                    Button(action: {
                        selectedMonth = month
                    }) {
                        Text(formatMonthYear(month))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                    }
                }
                
                // Current month (selected)
                Text(formatMonthYear(Date()))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(20)
                
                // Future months (lighter)
                ForEach(getNextMonths(), id: \.self) { month in
                    Button(action: {
                        selectedMonth = month
                    }) {
                        Text(formatMonthYear(month))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func buildBudgetOverviewCard() -> some View {
        VStack(spacing: 24) {
            // Top Row - Daily Budget and Spent So Far
            HStack(spacing: 0) {
                // Daily Budget
                VStack(spacing: 8) {
                    Text("You can spend")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(formatAmount(max(0, dailyBudget)))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Per Day")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 1, height: 80)
                
                // Spent So Far
                VStack(spacing: 8) {
                    Text("Spent so far")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(formatAmount(budget.spentAmount))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Total")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Divider Line
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
            
            // Bottom Row - Remaining and Budget
            HStack(spacing: 0) {
                // Remaining
                VStack(spacing: 8) {
                    Text("Remaining")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(formatAmount(max(0, budget.remainingAmount)))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(budget.remainingAmount < 0 ? .red : .primary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 1, height: 80)
                
                // Total Budget
                VStack(spacing: 8) {
                    Text("Budget")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(formatAmount(budget.budgetAmount))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Progress Bar and Timeline
            VStack(spacing: 12) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress
                        Rectangle()
                            .fill(getProgressColor())
                            .frame(
                                width: min(
                                    geometry.size.width * CGFloat(budget.progressPercentage / 100),
                                    geometry.size.width
                                ),
                                height: 8
                            )
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.3), value: budget.progressPercentage)
                    }
                }
                .frame(height: 8)
                
                // Timeline
                ScrollView(.horizontal, showsIndicators: false){
                    HStack {
                        Text(formatDate(budget.startDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatDate(budget.endDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Remaining Days
                Text("\(remainingDays) Remaining Days")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func buildActionButtons() -> some View {
        HStack(spacing: 16) {
            // Edit Button
            Button(action: {
                showEditBudget = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16))
                    
                    Text("Edit")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            // Delete Button
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                    
                    Text("Delete")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    @ViewBuilder
    private func buildViewTransactionsButton() -> some View {
        NavigationLink(destination: transactionViewTab()) {
            Text("View Transactions")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }.onAppear(perform: {
            navigationBarHidden(true)
            HStack{
                Image(systemName: "chevron.left")
                navigationTitle("Transactions")
            }
            
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func buildRecentTransactions() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                ForEach(Array(categoryTransactions.prefix(5)), id: \.id) { transaction in
                    HStack(spacing: 12) {
                        Text(transaction.category.emoji)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.description.isEmpty ? transaction.category.name : transaction.description)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(formatTransactionDate(transaction.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("-₹\(formatAmount(transaction.amount))")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getPreviousMonths() -> [Date] {
        let calendar = Calendar.current
        let currentDate = Date()
        var months: [Date] = []
        
        for i in 1...2 {
            if let month = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                months.append(month)
            }
        }
        
        return months.reversed()
    }
    
    private func getNextMonths() -> [Date] {
        let calendar = Calendar.current
        let currentDate = Date()
        var months: [Date] = []
        
        for i in 1...2 {
            if let month = calendar.date(byAdding: .month, value: i, to: currentDate) {
                months.append(month)
            }
        }
        
        return months
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTransactionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: date)
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
    
    private func getProgressColor() -> Color {
        switch budget.budgetStatus {
        case .onTrack:
            return .blue
        case .warning:
            return .orange
        case .overBudget:
            return .red
        }
    }
    
    private func deleteBudget() {
        budgetManager.deleteBudget(budget)
        dismiss()
    }
}

// MARK: - Edit Budget View
struct EditBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @ObservedObject var transactionManager: TransactionManager
    
    @State private var budgetAmount: String
    @State private var description: String
    @State private var sliderValue: Double
    
    init(budget: Budget, budgetManager: BudgetManager, transactionManager: TransactionManager) {
        self.budget = budget
        self.budgetManager = budgetManager
        self.transactionManager = transactionManager
        
        self._budgetAmount = State(initialValue: String(Int(budget.budgetAmount)))
        self._description = State(initialValue: budget.description)
        self._sliderValue = State(initialValue: budget.budgetAmount)
    }
    
    private var isFormValid: Bool {
        return !budgetAmount.isEmpty && (Double(budgetAmount) ?? 0) > 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Text("Edit Budget")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    saveBudget()
                }
                .disabled(!isFormValid)
                .foregroundColor(isFormValid ? .blue : .secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Content
            VStack(spacing: 24) {
                // Category Display (Read-only)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(budget.category.emoji)
                            .font(.title2)
                        Text(budget.category.name)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Budget Amount Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Budget Amount")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("₹0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("₹10,000")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $sliderValue, in: 0...10000, step: 100)
                            .accentColor(.black)
                    }
                    .padding(.horizontal, 4)
                    
                    HStack {
                        Text("₹")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        TextField("1000", text: $budgetAmount)
                            .font(.title2)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Description Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .frame(height: 100)
                        
                        TextEditor(text: $description)
                            .background(Color.clear)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        
                        if description.isEmpty {
                            Text("Add description...")
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .onChange(of: sliderValue) { newValue in
            budgetAmount = String(Int(newValue))
        }
        .onChange(of: budgetAmount) { newValue in
            if let doubleValue = Double(newValue), doubleValue >= 0 && doubleValue <= 10000 {
                sliderValue = doubleValue
            }
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(budgetAmount), amount > 0 else { return }
        
        var updatedBudget = budget
        updatedBudget.budgetAmount = amount
        updatedBudget.description = description.isEmpty ? "Budget for \(budget.category.name)" : description
        
        budgetManager.updateBudget(updatedBudget)
        dismiss()
    }
}

// MARK: - Category Transactions View
struct CategoryTransactionsView: View {
    let category: TransactionCategory
    let transactions: [Transaction]
    @ObservedObject var transactionManager: TransactionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                Text(category.emoji)
                    .font(.title2)
                
                Text("\(category.name) Transactions")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            if transactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "receipt")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Transactions")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("No transactions found for this category")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(transactions, id: \.id) { transaction in
                            TransactionRowView(transaction: transaction)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6))
    }
}

// MARK: - Transaction Row View
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Text(transaction.category.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description.isEmpty ? transaction.category.name : transaction.description)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.type == .income ? "+" : "-")₹\(formatAmount(transaction.amount))")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: date)
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

// MARK: - Preview
struct BudgetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let budgetManager = BudgetManager()
        let transactionManager = TransactionManager()
        let sampleCategory = TransactionCategory(name: "Food", emoji: "🍔", type: .expense)
        let sampleBudget = Budget(category: sampleCategory, budgetAmount: 1000, description: "Monthly food budget")
        
        BudgetDetailsView(
            budget: sampleBudget,
            budgetManager: budgetManager,
            transactionManager: transactionManager
        )
    }
}
