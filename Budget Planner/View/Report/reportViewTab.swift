//
//  ReportViewTab.swift
//  Budget Planner
//
//  Fixed version with proper chart updates
//

import SwiftUI
import Charts

struct ReportViewTab: View {
    @ObservedObject var transactionManager: TransactionManager
    @ObservedObject var budgetManager: BudgetManager
    @State private var selectedTab: ReportTab = .income
    @State private var selectedPeriod: TimePeriod = .thisMonth
    @StateObject private var currencyManager = CurrencyManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("Report")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        print("Filter button tapped")
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.black)
                            .font(.system(size: 30, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .padding(.top, -20)
                
                VStack {
                    tabSelector
                    
                    // Debug info
//                    VStack {
//                        Text("Total Transactions: \(transactionManager.transactions.count)")
//                        Text("Filtered: \(filteredTransactions.count)")
//                        Text("Income: \(incomeTransactions.count)")
//                        Text("Expense: \(expenseTransactions.count)")
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
                    
                    switch selectedTab {
                    case .expense:
                        expenseReportView
                    case .income:
                        incomeReportView
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .ignoresSafeArea()
        }
        .padding(.top)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = .income }) {
                Text("Income")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedTab == .income ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == .income ? Color.black : Color.clear
                    )
            }
            
            Button(action: { selectedTab = .expense }) {
                Text("Expense")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedTab == .expense ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == .expense ? Color.black : Color.clear
                    )
            }
        }
        .background(Color.gray.opacity(0.15))
        .cornerRadius(10)
    }
    
    // MARK: - Expense Report View
    private var expenseReportView: some View {
        VStack(spacing: 20) {
            // Expense Trend Chart
            if !expenseTransactions.isEmpty {
                lineChartView(transactions: expenseTransactions, title: "Expense", color: .red)
            } else {
                noDataView(message: "No expense transactions found")
            }
            
            // Category Distribution
            categoryDistributionView(transactions: expenseTransactions)
        }
    }
    
    // MARK: - Income Report View
    private var incomeReportView: some View {
        VStack(spacing: 20) {
            // Income Trend Chart
            if !incomeTransactions.isEmpty {
                lineChartView(transactions: incomeTransactions, title: "Income", color: .green)
            } else {
                noDataView(message: "No income transactions found")
            }
            
            // Category Distribution
            categoryDistributionView(transactions: incomeTransactions)
        }
    }
    
    // MARK: - No Data View
    private func noDataView(message: String) -> some View {
        VStack(spacing: 15) {
            Text("No Data")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Line Chart View (Using Charts library)
    private func lineChartView(transactions: [Transaction], title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Debug the data being passed
            let dailyData = dailyAmounts(for: transactions)
            
            if dailyData.isEmpty {
                Text("No data to display")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                // Using Charts library for line chart
                LineChartWrapper(data: dailyData, title: title, color: UIColor(color))
                    .frame(height: 200)
                    .id(UUID()) // Force refresh when data changes
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Category Distribution View
    private func categoryDistributionView(transactions: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Category Distribution")
                .font(.title2)
                .fontWeight(.semibold)
            
            let appCurrency = currencyManager.selectedCurrency.symbol
            
            if transactions.isEmpty {
                Text("No transactions found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 15) {
                    // Pie Chart using Charts library
                    let categoryData = categoryTotals(for: transactions)
                    let total = categoryData.reduce(0) { $0 + $1.amount }
                    
                    if categoryData.isEmpty {
                        Text("No category data available")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        VStack {
                            PieChartView(
                                data: categoryData.map { $0.amount },
                                title: "Total\n\(appCurrency)\(formatAmount(total))",
                                colors: categoryData.enumerated().map { index, _ in
                                    UIColor(colorForCategory(at: index))
                                }
                            )
                            .frame(height: 200)
                            .id(UUID()) // Force refresh when data changes
                        }
                        
                        // Category List
                        categoryList(for: transactions)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Category List
    private func categoryList(for transactions: [Transaction]) -> some View {
        let categoryData = categoryTotals(for: transactions)
        let total = categoryData.reduce(0) { $0 + $1.amount }
        
        return VStack(spacing: 12) {
            ForEach(Array(categoryData.enumerated()), id: \.offset) { index, data in
                HStack {
                    // Color indicator
                    Circle()
                        .fill(colorForCategory(at: index))
                        .frame(width: 12, height: 12)
                    
                    // Category info
                    HStack {
                        Text("\(data.category.emoji) \(data.category.name)")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(Int((data.amount / total) * 100))%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(currencyManager.selectedCurrency.symbol + formatAmount(data.amount))
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Extensions and Helper Methods
extension ReportViewTab {
    
    // MARK: - Computed Properties
    private var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return (startOfWeek, endOfWeek)
            
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return (startOfMonth, endOfMonth)
            
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
            return (startOfYear, endOfYear)
        }
    }
    
    private var filteredTransactions: [Transaction] {
        let range = dateRange
        return transactionManager.transactions.filter { transaction in
            transaction.date >= range.start && transaction.date <= range.end
        }
    }
    
    private var expenseTransactions: [Transaction] {
        filteredTransactions.filter { $0.type == .expense }
    }
    
    private var incomeTransactions: [Transaction] {
        filteredTransactions.filter { $0.type == .income }
    }
    
    private var totalIncome: Double {
        incomeTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        expenseTransactions.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Helper Functions
    private func dailyAmounts(for transactions: [Transaction]) -> [Double] {
        guard !transactions.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        let sorted = grouped.sorted { $0.key < $1.key }
        return sorted.map { _, transactions in
            transactions.reduce(0) { $0 + $1.amount }
        }
    }
    
    private func categoryTotals(for transactions: [Transaction]) -> [CategoryTotal] {
        guard !transactions.isEmpty else { return [] }
        
        let grouped = Dictionary(grouping: transactions) { $0.category.id }
        
        return grouped.compactMap { _, transactions in
            guard let firstTransaction = transactions.first else { return nil }
            return CategoryTotal(
                category: firstTransaction.category,
                amount: transactions.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func colorForCategory(at index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow, .red, .gray]
        return colors[index % colors.count]
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

// MARK: - Custom Chart Views using Charts library

struct LineChartWrapper: UIViewRepresentable {
    var data: [Double]
    let title: String
    let color: UIColor
    
    func makeUIView(context: Context) -> LineChartView {
        let chartView = Charts.LineChartView()
        setupChartView(chartView)
        return chartView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        updateChartData(uiView)
    }
    
    private func setupChartView(_ chartView: LineChartView) {
        chartView.backgroundColor = UIColor.systemBackground
        chartView.gridBackgroundColor = UIColor.systemBackground
        chartView.drawBordersEnabled = false
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        
        // Configure axes
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        
        chartView.rightAxis.enabled = false
    }
    
    private func updateChartData(_ chartView: LineChartView) {
        guard !data.isEmpty else {
            chartView.data = nil
            return
        }
        
        let entries = data.enumerated().map { index, value in
            ChartDataEntry(x: Double(index), y: value)
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: title)
        dataSet.colors = [color]
        dataSet.lineWidth = 3
        dataSet.circleRadius = 4
        dataSet.circleColors = [color]
        dataSet.mode = .cubicBezier
        dataSet.fillColor = color
        dataSet.fillAlpha = 0.3
        dataSet.drawFilledEnabled = true
        dataSet.drawValuesEnabled = false
        
        let chartData = LineChartData(dataSet: dataSet)
        chartView.data = chartData
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}

struct PieChartView: UIViewRepresentable {
    let data: [Double]
    let title: String
    let colors: [UIColor]
    
    func makeUIView(context: Context) -> Charts.PieChartView {
        let chartView = Charts.PieChartView()
        setupChartView(chartView)
        return chartView
    }
    
    func updateUIView(_ uiView: Charts.PieChartView, context: Context) {
        updateChartData(uiView)
    }
    
    private func setupChartView(_ chartView: Charts.PieChartView) {
        chartView.backgroundColor = UIColor.systemBackground
        chartView.holeRadiusPercent = 0.4
        chartView.transparentCircleRadiusPercent = 0.45
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        
        // Center text
        chartView.centerText = title
        chartView.centerTextRadiusPercent = 1.0
    }
    
    private func updateChartData(_ uiView: Charts.PieChartView) {
        guard !data.isEmpty else {
            uiView.data = nil
            return
        }
        
        let entries = data.enumerated().map { index, value in
            PieChartDataEntry(value: value)
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = colors
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 2
        
        let chartData = PieChartData(dataSet: dataSet)
        uiView.data = chartData
        uiView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}

// MARK: - Supporting Types
enum ReportTab {
    case income
    case expense
}

enum TimePeriod: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
}

struct CategoryTotal {
    let category: TransactionCategory
    let amount: Double
}

// MARK: - Preview
struct ReportViewTab_Previews: PreviewProvider {
    static var previews: some View {
        ReportViewTab(
            transactionManager: TransactionManager(),
            budgetManager: BudgetManager()
        )
    }
}
