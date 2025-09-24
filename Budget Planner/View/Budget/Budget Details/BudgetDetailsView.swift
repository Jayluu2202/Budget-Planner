//
//  BudgetDetailsView.swift
//  Budget Planner
//
//  FIXED VERSION: Proper navigation handling
//

import SwiftUI

struct BudgetDetailsView: View {
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @ObservedObject var transactionManager: TransactionManager
    @ObservedObject var currencyManager = CurrencyManager()
    
    
    // Use presentationMode for NavigationView back navigation
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showEditBudget = false
    @State private var showDeleteAlert = false
    @State private var selectedMonth = Date()
    @State private var showTransactions = false
    @State private var navigate = false

    
    // Computed properties for budget calculations
    private var dailyBudget: Double {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)
        let totalDaysInMonth = range?.count ?? 30
        
        // Calculate days passed within the selected month.
        let today = Date()
        let daysPassedInSelectedMonth = calendar.isDate(today, equalTo: selectedMonth, toGranularity: .month) ? calendar.component(.day, from: today) : totalDaysInMonth
        
        // Calculate remaining days for the rest of the selected month
        let remainingDaysInSelectedMonth = max(0, totalDaysInMonth - daysPassedInSelectedMonth + 1)
        
        // Ensure you don't divide by zero
        let remainingAmount = budget.budgetAmount - spentForThisBudget
        return remainingDaysInSelectedMonth > 0 ? remainingAmount / Double(remainingDaysInSelectedMonth) : 0
    }

    private var currencySymbol: String {
            currencyManager.selectedCurrency.symbol
        }
    
    private var remainingDays: Int {
        let calendar = Calendar.current
        let today = Date()
        
        // If the selected month is the current month, calculate remaining days from today.
        if calendar.isDate(selectedMonth, equalTo: today, toGranularity: .month) {
            let range = calendar.range(of: .day, in: .month, for: today)
            let totalDaysInMonth = range?.count ?? 30
            let daysPassed = calendar.component(.day, from: today)
            return max(0, totalDaysInMonth - daysPassed)
        } else {
            // If it's a past or future month, there are no "remaining" days in the same sense.
            return 0
        }
    }
    
    private var categoryTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactionManager.transactions
            .filter { transaction in
                transaction.category.id == budget.category.id &&
                calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month) &&
                calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .year)
            }
            .sorted { $0.date > $1.date }
    }
    
    private var spentForThisBudget: Double {
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
    
    private var progressPercentage: Double {
        guard budget.budgetAmount > 0 else { return 0 }
        return (spentForThisBudget / budget.budgetAmount) * 100
    }
    
    var body: some View {
        VStack {
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
                        .padding(.horizontal, 20)
                    // Recent Transactions (if any)
                    if !categoryTransactions.isEmpty {
                        buildRecentTransactions()
                    
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, -40)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color(.white))
        .sheet(isPresented: $showEditBudget) {
            EditBudgetView(
                budget: budget,
                budgetManager: budgetManager,
                transactionManager: transactionManager, currencyManager: currencyManager
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
        VStack{
            HStack(spacing: 12) {
                // Back Button - FIXED: Use presentationMode.wrappedValue.dismiss()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    print("Navigating back to budget overview")
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    // Category Icon and Name
                    Text(budget.category.emoji)
                        .font(.title2)
                    
                    Text(budget.category.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Divider()
        }
        .padding(.top, 60)
        .background(Color(.white))
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    private func buildMonthSelection() -> some View {
        let calendar = Calendar.current
        let today = Date()
        
        ScrollView(.horizontal, showsIndicators: false){
            HStack {
                // Previous months (lighter)
                ForEach(getPreviousMonths(around: today), id: \.self) { month in
                    let isSelected = calendar.isDate(month, equalTo: selectedMonth, toGranularity: .month)
                    Button(action: {
                        selectedMonth = month
                        
                    }) {
                        Text(formatMonthYear(month))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(isSelected ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Color.black : Color(.white))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? .clear: .gray, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 1)
                
                let isSelected = calendar.isDate(today, equalTo: selectedMonth, toGranularity: .month)
                Button(action: {
                    selectedMonth = today
                }) {
                    // Current month (selected)
                    Text(formatMonthYear(today))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.black : Color(.white))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? .clear : .gray)
                        )
                }
            }
        }
    }
    
    @ViewBuilder
    private func buildBudgetOverviewCard() -> some View {
        let actualCurrency = currencyManager.selectedCurrency.symbol
        
        VStack(spacing: 12) {
            // Top Row - Daily Budget and Spent So Far
            HStack(spacing: 0) {
                // Daily Budget
                VStack(spacing: 4) {
                    Text("You can spend")
                        .font(.body)
                        .foregroundColor(.secondary)
                        
                    Text("\(actualCurrency)\(formatAmount(max(0, dailyBudget)))")
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
                    .padding(.bottom, -25)
                
                // Spent So Far
                VStack(spacing: 4) {
                    Text("Spent so far")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("\(actualCurrency)\(String(format: "%.2f", spentForThisBudget))")
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
                    
                    Text("\(actualCurrency)\(String(format: "%.2f", budget.budgetAmount - spentForThisBudget))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(budget.remainingAmount < 0 ? .red : .primary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 1, height: 80)
                    .padding(.top, -25)
                // Total Budget
                VStack(spacing: 8) {
                    Text("Budget")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("\(actualCurrency)\(formatAmount(budget.budgetAmount))")
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
                            .fill(.black)
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
                
                // Timeline
                HStack {
                    let calendar = Calendar.current
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: budget.startDate)) ?? budget.startDate
                    let lastOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? budget.endDate
                    
                    //1st date of the month
                    Text(formatDate(startOfMonth))
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.7))
                    
                    Spacer()
                    // last date of the month
                    Text(formatDate(lastOfMonth))
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.7))
                }
                
                // Remaining Days
                Text("\(remainingDays) Remaining Days")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 4)
        )
        .cornerRadius(16)
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
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("Edit")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.black), lineWidth: 2)
                )
            }
            
            // Delete Button
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Delete")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 2)
                )
            }
        }
    }
    
    
    @ViewBuilder
    private func buildViewTransactionsButton() -> some View {
        NavigationLink(
            destination: transactionViewTab(category: budget.category)
        ) {
            Text("View Transactions")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func buildRecentTransactions() -> some View {
        let actualCurrency = currencyManager.selectedCurrency.symbol
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
                        
                        Text("-\(actualCurrency)\(formatAmount(transaction.amount))")
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
    
    private func getPreviousMonths(around date: Date) -> [Date] {
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
    
    private func deleteBudget() {
        budgetManager.deleteBudget(budget)
        presentationMode.wrappedValue.dismiss() // FIXED: Use presentationMode for delete as well
    }
}

// MARK: - Edit Budget View
struct EditBudgetView: View {
    @Environment(\.dismiss) private var dismiss // This is correct for sheets
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @ObservedObject var transactionManager: TransactionManager
    @ObservedObject var currencyManager: CurrencyManager
    @State private var budgetAmount: String
    @State private var description: String
    @State private var sliderValue: Double
    
    private var actualCurrency: String{
        currencyManager.selectedCurrency.symbol
    }
    
    init(budget: Budget, budgetManager: BudgetManager, transactionManager: TransactionManager, currencyManager: CurrencyManager) {
        self.budget = budget
        self.budgetManager = budgetManager
        self.transactionManager = transactionManager
        self.currencyManager = currencyManager
        
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
                            Text("\(actualCurrency)0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(actualCurrency)10,000")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $sliderValue, in: 0...10000, step: 100)
                            .accentColor(.black)
                    }
                    .padding(.horizontal, 4)
                    
                    HStack {
                        Text("\(actualCurrency)")
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
                            .padding(10)
                            .frame(height: 100)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        
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

// MARK: - Preview
struct BudgetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let budgetManager = BudgetManager()
        let transactionManager = TransactionManager()
        let currenctManager = CurrencyManager()
        // Sample Account
        let sampleAccount = Account(id: UUID(), name: "Cash", emoji: "💰", balance: 5000)
        
        // Sample Category
        let sampleCategory = TransactionCategory(id: UUID(), name: "Food", emoji: "🍔", type: .expense)
        
        // Sample Budget
        let sampleBudget = Budget(
            category: sampleCategory,
            budgetAmount: 1000,
            description: "Monthly food budget",
            startDate: Date().addingTimeInterval(-5 * 24 * 60 * 60), // 5 days ago
            endDate: Date().addingTimeInterval(25 * 24 * 60 * 60)
        )
        
        // Sample Transactions
        let sampleTransactions = [
            Transaction(
                type: .expense,
                amount: 200,
                description: "Lunch at cafe",
                date: Date().addingTimeInterval(-3 * 24 * 60 * 60), // 3 days ago
                account: sampleAccount,
                category: sampleCategory
            ),
            Transaction(
                type: .expense,
                amount: 100,
                description: "Groceries",
                date: Date().addingTimeInterval(-1 * 24 * 60 * 60), // 1 day ago
                account: sampleAccount,
                category: sampleCategory
            )
        ]
        
        BudgetDetailsView(
            budget: sampleBudget,
            budgetManager: budgetManager,
            transactionManager: transactionManager, currencyManager: currenctManager
        )
    }
}

