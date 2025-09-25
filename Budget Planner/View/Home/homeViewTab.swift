//
//  homeViewTab.swift
//  Budget Planner
//
//  Fixed to include BudgetManager integration
//

import SwiftUI

struct homeViewTab: View {
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var showAddScreen = false
    @State private var navigateToWealth = false
    @StateObject private var transactionManager = TransactionManager()
    @StateObject private var budgetManager = BudgetManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Greeting Section
                buildGreetingSection()
                
                // Main scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        buildCalendarSection()
                        buildTransactionsSection()
                    }
                    .padding(.top, 8)
                }

                // Hidden NavigationLink
                NavigationLink(
                    destination: MyWealth(),
                    isActive: $navigateToWealth
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button {
                        showAddScreen = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 10)
            .navigationBarHidden(true)
        }
        .onAppear {
            transactionManager.loadData()
            budgetManager.loadData() // Load budget data
        }
        .sheet(isPresented: $showAddScreen) {
            // Pass both managers to AddTransactionDetails
            AddTransactionDetails(
                transactionManager: transactionManager,
                budgetManager: budgetManager
            )
        }
    }

    // Rest of the code remains the same...
    @ViewBuilder
    private func buildGreetingSection() -> some View {
        HStack {
            Text("Hey! \(getGreeting())")
                .font(.headline)
            
            Image("WaveHand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Spacer()
            
            Button {
                handleWealthButtonTap()
                navigateToWealth = true
            } label: {
                Image("Wealth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
        }
    }
    
    func getGreeting() -> String{
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour{
        case 5..<12:
                return "Good Morning"
            case 12..<17:
                return "Good Afternoon"
            case 17..<21:
                return "Good Evening"
            default:
                return "Good Night"
        }
    }
    
    @ViewBuilder
    private func buildCalendarSection() -> some View {
        VStack(spacing: 16) {
            buildMonthNavigation()
            CalendarView(
                currentDate: $currentDate,
                selectedDate: $selectedDate,
                transactionManager: transactionManager
            )
        }
    }
    
    @ViewBuilder
    private func buildMonthNavigation() -> some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .padding(8)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(width: 200)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
    }
    
    @ViewBuilder
    private func buildTransactionsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transactions for \(selectedDayString)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let dayTransactions = transactionManager.transactionsForDate(selectedDate)
            
            if dayTransactions.isEmpty {
                HStack {
                    Text("No transactions for this date")
                        .font(.body)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ForEach(dayTransactions) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(transaction.category.emoji)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(transaction.category.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    Text(transaction.account.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(CurrencyManager().selectedCurrency.symbol)\(Int(transaction.amount))")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(transaction.type == .income ? .green : .red)
                    }
                    .padding(.vertical, 8)
                    
                    if transaction.id != dayTransactions.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
    
    private func handleWealthButtonTap() {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let startWeekday = Calendar.current.component(.weekday, from: startOfMonth) - 1
        print("Wealth button tapped - Start weekday: \(startWeekday)")
    }
    
    private func previousMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var selectedDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

// Calendar and DayView components remain the same...
struct CalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @ObservedObject var transactionManager: TransactionManager
    
    var body: some View {
        VStack(spacing: 12) {
            buildWeekdayHeader()
            buildCalendarGrid()
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func buildWeekdayHeader() -> some View {
        HStack(spacing: 0) {
            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private func buildCalendarGrid() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(getAllDaysInMonth(), id: \.self) { date in
                if let date = date {
                    DayView(
                        date: date,
                        currentMonth: currentDate,
                        selectedDate: $selectedDate,
                        transactionManager: transactionManager
                    )
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 50)
                }
            }
        }
    }
    
    private func getAllDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        var days: [Date?] = []
        
        let startWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        for _ in 0..<startWeekday {
            days.append(nil)
        }
        
        var currentDay = startOfMonth
        while currentDay < endOfMonth {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
        }
        
        return days
    }
}

struct DayView: View {
    let date: Date
    let currentMonth: Date
    @Binding var selectedDate: Date
    @ObservedObject var transactionManager: TransactionManager
    
    private var hasTransactions: Bool {
        return !transactionManager.transactionsForDate(date).isEmpty
    }
    
    private var budgetValue: String {
        let dayTransactions = transactionManager.transactionsForDate(date)
        let totalAmount = dayTransactions.reduce(0) { total, transaction -> Int in
            switch transaction.type {
            case .income:
                return total + Int(transaction.amount)
            case .expense:
                return total - Int(transaction.amount)
            case .transfer:
                return total
            }
        }
        let actualCurrency = CurrencyManager().selectedCurrency.symbol
        if totalAmount == 0 && hasTransactions {
            return "\(actualCurrency)0"
        } else if totalAmount == 0 {
            return ""
        } else if totalAmount > 0 {
            return "\(actualCurrency)\(Int(totalAmount))"
        } else {
            return "\(actualCurrency)\(Int(abs(totalAmount)))"
        }
    }
    
    private var budgetValueColor: Color {
        let dayTransactions = transactionManager.transactionsForDate(date)
        let totalAmount = dayTransactions.reduce(0) { total, transaction in
            switch transaction.type {
            case .income:
                return total + Int(transaction.amount)
            case .expense:
                return total - Int(transaction.amount)
            case .transfer:
                return total
            }
        }
        
        if totalAmount > 0 {
            return .green
        } else if totalAmount < 0 {
            return .red
        } else if hasTransactions {
            return .orange
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(budgetValue)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(budgetValueColor)
                let actualCurrency = CurrencyManager().selectedCurrency.symbol
                if hasTransactions && budgetValue == "\(actualCurrency)0" {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 45, height: 55)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: strokeWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var textColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .primary
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        return Color.clear
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .orange
        } else if hasTransactions {
            return .gray.opacity(0.6)
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        if isSelected {
            return 2.0
        } else if isToday {
            return 1.5
        } else if hasTransactions {
            return 1.0
        } else {
            return 0.5
        }
    }
}

struct homeViewTab_preview: PreviewProvider {
    static var previews: some View {
        homeViewTab()
    }
}
