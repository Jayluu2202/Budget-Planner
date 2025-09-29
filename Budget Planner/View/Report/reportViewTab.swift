//
//  ReportViewTab.swift
//  Budget Planner
//
//  Updated version with Dark Mode compatibility fixes
//

import SwiftUI
import Charts

struct ReportViewTab: View {
    @ObservedObject var transactionManager: TransactionManager
    @ObservedObject var budgetManager: BudgetManager
    @State private var selectedTab: ReportTab = .income
    @State private var selectedPeriod: TimePeriod = .thisMonth
    @State private var showingFilterSheet = false
    @StateObject private var currencyManager = CurrencyManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header section - fixed positioning
                VStack(spacing: 0) {
                    HStack {
                        Text("Report")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary) // Dynamic color
                        
                        Spacer()
                        
                        Button(action: {
                            showingFilterSheet = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary) // Dynamic color
                                .font(.system(size: 24, weight: .medium))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Divider()
                        .padding(.top, 8)
                        .padding(.horizontal)
                }
                .background(Color(.systemBackground)) // Dynamic background
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Tab selector
                        tabSelector
                            .padding(.horizontal)
                        
                        // Period info
                        HStack {
                            Text("Period: \(selectedPeriod.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(filteredTransactions.count) transactions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Content based on selected tab
                        Group {
                            switch selectedTab {
                            case .expense:
                                expenseReportView
                            case .income:
                                incomeReportView
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bottom spacing for tab bar
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .background(
                Color(.systemGroupedBackground) // Better dark mode background
                    .ignoresSafeArea()
            )
            .overlay(
                // HalfSheet overlay
                HalfSheet(isPresented: $showingFilterSheet) {
                    TimeFilterHalfSheet(selectedPeriod: $selectedPeriod, isPresented: $showingFilterSheet)
                }
                .allowsHitTesting(false)
            )
        }
        .padding(.vertical, scaleH(-150))
        .navigationBarHidden(true)
    }
    
    private func scaleH(_ value: CGFloat) -> CGFloat {
        let deviceHeight = UIScreen.main.bounds.height
        let screenvalue = deviceHeight / 956
        return value * screenvalue
    }
    
    private func scaleW(_ value: CGFloat) -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        let screenValue = deviceWidth / 452
        return value * screenValue
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = .income }) {
                Text("Income")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedTab == .income ? Color(.systemBackground) : .primary) // Dynamic text color
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == .income ? Color.primary : Color.clear
                    )
            }
            
            Button(action: { selectedTab = .expense }) {
                Text("Expense")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedTab == .expense ? Color(.systemBackground) : .primary) // Dynamic text color
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == .expense ? Color.primary : Color.clear
                    )
            }
        }
        .background(Color(.systemFill)) // Better background for dark mode
        .cornerRadius(10)
    }
    
    // MARK: - Expense Report View
    private var expenseReportView: some View {
        VStack(spacing: 20) {
            // Expense Trend Chart
            if !expenseTransactions.isEmpty {
                lineChartView(transactions: expenseTransactions, title: "Expense Trend", color: .red)
            } else {
                noDataView(message: "No expense transactions found for \(selectedPeriod.rawValue.lowercased())")
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
                lineChartView(transactions: incomeTransactions, title: "Income Trend", color: .green)
            } else {
                noDataView(message: "No income transactions found for \(selectedPeriod.rawValue.lowercased())")
            }
            
            // Category Distribution
            categoryDistributionView(transactions: incomeTransactions)
        }
    }
    
    // MARK: - No Data View
    private func noDataView(message: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Data")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary) // Dynamic color
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)) // Better card background
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 1) // Subtle shadow for dark mode
    }
    
    // MARK: - Line Chart View
    private func lineChartView(transactions: [Transaction], title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary) // Dynamic color
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    let total = transactions.reduce(0) { $0 + $1.amount }
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currencyManager.selectedCurrency.symbol)\(formatAmount(total))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
            }
            
            let chartData = prepareChartData(for: transactions)
            
            if chartData.isEmpty {
                Text("No data to display")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                LineChartWrapper(
                    data: chartData,
                    title: title,
                    color: UIColor(color),
                    period: selectedPeriod
                )
                .frame(height: 200)
                .id("\(selectedPeriod)-\(selectedTab)-\(UUID())")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)) // Better card background
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 1) // Subtle shadow
    }
    
    // MARK: - Category Distribution View
    private func categoryDistributionView(transactions: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Category Distribution")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary) // Dynamic color
            
            if transactions.isEmpty {
                Text("No transactions found for \(selectedPeriod.rawValue.lowercased())")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 15) {
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
                                title: "Total\n\(currencyManager.selectedCurrency.symbol)\(formatAmount(total))",
                                colors: categoryData.enumerated().map { index, _ in
                                    UIColor(colorForCategory(at: index))
                                }
                            )
                            .frame(height: 200)
                            .id("\(selectedPeriod)-\(selectedTab)-pie-\(UUID())")
                        }
                        
                        // Category List
                        categoryList(for: transactions)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)) // Better card background
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 1) // Subtle shadow
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
                            .foregroundColor(.primary) // Dynamic color
                        
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
                .background(Color(.tertiarySystemGroupedBackground)) // Better row background
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Extensions and Helper Methods
extension ReportViewTab {
    
    // MARK: - Computed Properties with Dynamic Filtering
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
            
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let startOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
            let endOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
            return (startOfLastMonth, endOfLastMonth)
            
        case .last3Months:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            let startOfThreeMonthsAgo = calendar.dateInterval(of: .month, for: threeMonthsAgo)?.start ?? now
            return (startOfThreeMonthsAgo, now)
            
        case .last6Months:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            let startOfSixMonthsAgo = calendar.dateInterval(of: .month, for: sixMonthsAgo)?.start ?? now
            return (startOfSixMonthsAgo, now)
            
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
    
    // MARK: - Helper Functions for Chart Data
    private func prepareChartData(for transactions: [Transaction]) -> [(Date, Double)] {
        guard !transactions.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let range = dateRange
        
        // Group transactions by appropriate time unit based on selected period
        let groupedData: [Date: Double]
        
        switch selectedPeriod {
        case .thisWeek, .thisMonth, .lastMonth:
            // Group by day
            groupedData = Dictionary(grouping: transactions) { transaction in
                calendar.startOfDay(for: transaction.date)
            }.mapValues { dayTransactions in
                dayTransactions.reduce(0) { $0 + $1.amount }
            }
            
        case .last3Months, .last6Months:
            // Group by week
            groupedData = Dictionary(grouping: transactions) { transaction in
                let weekInterval = calendar.dateInterval(of: .weekOfYear, for: transaction.date)
                return weekInterval?.start ?? transaction.date
            }.mapValues { weekTransactions in
                weekTransactions.reduce(0) { $0 + $1.amount }
            }
            
        case .thisYear:
            // Group by month
            groupedData = Dictionary(grouping: transactions) { transaction in
                let monthInterval = calendar.dateInterval(of: .month, for: transaction.date)
                return monthInterval?.start ?? transaction.date
            }.mapValues { monthTransactions in
                monthTransactions.reduce(0) { $0 + $1.amount }
            }
        }
        
        // Convert to sorted array
        return groupedData.sorted { $0.key < $1.key }
    }
    
    private func dailyAmounts(for transactions: [Transaction]) -> [Double] {
        let chartData = prepareChartData(for: transactions)
        return chartData.map { $0.1 }
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
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow, .red, .secondary, .mint, .cyan]
        return colors[index % colors.count]
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

// MARK: - Updated Chart Components with Dark Mode Support

struct LineChartWrapper: UIViewRepresentable {
    var data: [(Date, Double)]
    let title: String
    let color: UIColor
    let period: TimePeriod
    
    func makeUIView(context: Context) -> LineChartView {
        let chartView = Charts.LineChartView()
        setupChartView(chartView)
        return chartView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        updateChartData(uiView)
        updateChartAppearance(uiView) // Update colors for dark mode
    }
    
    private func setupChartView(_ chartView: LineChartView) {
        chartView.drawBordersEnabled = false
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        
        updateChartAppearance(chartView)
        
        // Configure axes
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawLabelsEnabled = true
        chartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        
        chartView.rightAxis.enabled = false
    }
    
    private func updateChartAppearance(_ chartView: LineChartView) {
        // Dynamic colors based on current interface style
        chartView.backgroundColor = UIColor.secondarySystemGroupedBackground
        chartView.gridBackgroundColor = UIColor.secondarySystemGroupedBackground
        
        chartView.xAxis.gridColor = UIColor.separator
        chartView.xAxis.labelTextColor = UIColor.secondaryLabel
        
        chartView.leftAxis.gridColor = UIColor.separator
        chartView.leftAxis.labelTextColor = UIColor.secondaryLabel
    }
    
    private func updateChartData(_ chartView: LineChartView) {
        guard !data.isEmpty else {
            chartView.data = nil
            return
        }
        
        let entries = data.enumerated().map { index, dateValue in
            ChartDataEntry(x: Double(index), y: dateValue.1)
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: title)
        dataSet.colors = [color]
        dataSet.lineWidth = 3
        dataSet.circleRadius = 4
        dataSet.circleColors = [color]
        dataSet.mode = .cubicBezier
        dataSet.fillColor = color
        dataSet.fillAlpha = 0.2
        dataSet.drawFilledEnabled = true
        dataSet.drawValuesEnabled = false
        
        // Set up X-axis labels based on period
        let formatter = DateFormatter()
        switch period {
        case .thisWeek, .thisMonth, .lastMonth:
            formatter.dateFormat = "MMM dd"
        case .last3Months, .last6Months:
            formatter.dateFormat = "MMM dd"
        case .thisYear:
            formatter.dateFormat = "MMM"
        }
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map {
            formatter.string(from: $0.0)
        })
        
        let chartData = LineChartData(dataSet: dataSet)
        chartView.data = chartData
        chartView.animate(xAxisDuration: 0.8, yAxisDuration: 0.8)
    }
}

// PieChartView with Dark Mode Support
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
        updateChartAppearance(uiView) // Update colors for dark mode
    }
    
    private func setupChartView(_ chartView: Charts.PieChartView) {
        chartView.holeRadiusPercent = 0.4
        chartView.transparentCircleRadiusPercent = 0.45
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        
        updateChartAppearance(chartView)
        
        // Center text
        chartView.centerText = title
        chartView.centerTextRadiusPercent = 1.0
    }
    
    private func updateChartAppearance(_ chartView: Charts.PieChartView) {
        // Dynamic colors
        chartView.backgroundColor = UIColor.secondarySystemGroupedBackground
        chartView.holeColor = UIColor.secondarySystemGroupedBackground
        chartView.transparentCircleColor = UIColor.secondarySystemGroupedBackground
        
        // Center text color
        let centerTextColor = UIColor.label
        let mutableString = NSMutableAttributedString(string: title)
        mutableString.addAttribute(.foregroundColor,
                                  value: centerTextColor,
                                  range: NSRange(location: 0, length: title.count))
        chartView.centerAttributedText = mutableString
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
        uiView.animate(xAxisDuration: 0.8, yAxisDuration: 0.8)
    }
}

// MARK: - Updated HalfSheet Filter View with Dark Mode Support
struct TimeFilterHalfSheet: View {
    @Binding var selectedPeriod: TimePeriod
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Grab handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Header
            HStack {
                Button("Reset") {
                    selectedPeriod = .thisMonth
                }
                .foregroundColor(.primary) // Dynamic color
                
                Spacer()
                
                Text("Filter")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary) // Dynamic color
                
                Spacer()
                
                Button("Done") {
                    isPresented = false
                }
                .foregroundColor(.primary) // Dynamic color
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Period options
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                        }) {
                            HStack {
                                Text(period.rawValue)
                                    .font(.body)
                                    .foregroundColor(.primary) // Dynamic color
                                
                                Spacer()
                                
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                Rectangle()
                                    .fill(selectedPeriod == period ? Color.accentColor.opacity(0.15) : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Spacer()
        }
        .background(Color(.systemBackground)) // Dynamic background
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

// MARK: - Updated HalfSheet Implementation
struct HalfSheet<Content: View>: UIViewControllerRepresentable {
    var content: Content
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetViewController {
        let controller = HalfSheetViewController()
        controller.onDismiss = {
            DispatchQueue.main.async {
                self.isPresented = false
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: HalfSheetViewController, context: Context) {
        if isPresented && !uiViewController.isPresenting {
            uiViewController.presentSheet(with: content)
        } else if !isPresented && uiViewController.isPresenting {
            uiViewController.dismissSheet()
        }
    }
}

// MARK: - Helper UIViewController for HalfSheet
class HalfSheetViewController: UIViewController {
    var isPresenting = false
    var onDismiss: (() -> Void)?
    private var currentHostingController: UIHostingController<AnyView>?
    
    func presentSheet<Content: View>(with content: Content) {
        guard !isPresenting else { return }
        
        let hostingController = UIHostingController(rootView: AnyView(content))
        hostingController.modalPresentationStyle = .pageSheet
        
        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 16
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        
        // Set up dismiss handling
        hostingController.presentationController?.delegate = self
        
        currentHostingController = hostingController
        isPresenting = true
        
        present(hostingController, animated: true)
    }
    
    func dismissSheet() {
        guard isPresenting, let hostingController = currentHostingController else { return }
        
        isPresenting = false
        hostingController.dismiss(animated: true) { [weak self] in
            self?.currentHostingController = nil
        }
    }
}

extension HalfSheetViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isPresenting = false
        currentHostingController = nil
        onDismiss?()
    }
}

// MARK: - Supporting Types
enum ReportTab {
    case income
    case expense
}

enum TimePeriod: String, CaseIterable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case last3Months = "Last 3 Months"
    case last6Months = "Last 6 Months"
    case thisYear = "This Year"
    case thisWeek = "This Week"
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
        .preferredColorScheme(.dark) // Preview in dark mode
    }
}
