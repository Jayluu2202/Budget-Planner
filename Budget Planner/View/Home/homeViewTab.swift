//
//  homeViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

// 🏠 Main Home View Component
struct homeViewTab: View {
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var showAddScreen = false
    @State private var navigateToWealth = false
    @StateObject private var transactionManager = TransactionManager() // Add TransactionManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 👋 Greeting Section
                buildGreetingSection()
                
                // Main scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        buildCalendarSection()
                        buildTransactionsSection()
                    }
                    .padding(.top, 8)
                }

                // ✅ Hidden NavigationLink (MUST be inside VStack)
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
        }
        .sheet(isPresented: $showAddScreen) {
            AddTransactionDetails(transactionManager: transactionManager)
        }
    }


    
    // MARK: - 🏗️ View Builders
    
    @ViewBuilder
    private func buildGreetingSection() -> some View {
        HStack {
            Text("Hey! Greetings")
                .font(.headline)
            
            Image("WaveHand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Spacer()
            
            // ✅ SIMPLIFIED BUTTON ACTION
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
    
    @ViewBuilder
    private func buildCalendarSection() -> some View {
        VStack(spacing: 16) {
            // 🔄 Month Navigation
            buildMonthNavigation()
            
            // 📅 Calendar Grid
            CalendarView(
                currentDate: $currentDate,
                selectedDate: $selectedDate,
                transactionManager: transactionManager // Pass transaction manager
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
            
            // 📝 Real Transactions for Selected Date
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
                        
                        Text("₹\(Int(transaction.amount))")
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
    
    // MARK: - 🔧 Helper Functions
    
    private func handleWealthButtonTap() {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let startWeekday = Calendar.current.component(.weekday, from: startOfMonth) - 1
        print("💰 Wealth button tapped - Start weekday: \(startWeekday)")
    }
    
    private func handleAddButtonTap() {
        print("➕ Add button tapped! Ready to add new transaction")
    }
    
    private func previousMonth() {
        withAnimation(.linear(duration: 0.3)) {
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    private func nextMonth() {
        withAnimation(.linear(duration: 0.3)) {
            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }
    
    // MARK: - 📊 Computed Properties
    
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

// MARK: - 📅 Calendar View Component
struct CalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @ObservedObject var transactionManager: TransactionManager // Add this
    
    var body: some View {
        VStack(spacing: 12) {
            // 📋 Days of the week header
            buildWeekdayHeader()
            
            // 🗓️ Calendar grid
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
                        transactionManager: transactionManager // Pass transaction manager
                    )
                } else {
                    // 🚫 Empty space for days not in current month
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 50)
                }
            }
        }
    }
    
    // 📅 Function to get all days in the current month
    private func getAllDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        var days: [Date?] = []
        
        // ⬅️ Add empty spaces for days before the first day of the month
        let startWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        for _ in 0..<startWeekday {
            days.append(nil)
        }
        
        // 📆 Add all days of the current month
        var currentDay = startOfMonth
        while currentDay < endOfMonth {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
        }
        
        return days
    }
}

// MARK: - 📍 Individual Day View Component
struct DayView: View {
    let date: Date
    let currentMonth: Date
    @Binding var selectedDate: Date
    @ObservedObject var transactionManager: TransactionManager
    
    // Check if there are any transactions for this day
    private var hasTransactions: Bool {
        return !transactionManager.transactionsForDate(date).isEmpty
    }
    
    // 💰 Calculate actual budget value for each day
    private var budgetValue: String {
        let dayTransactions = transactionManager.transactionsForDate(date)
        let totalAmount = dayTransactions.reduce(0) { total, transaction -> Int in
            switch transaction.type {
            case .income:
                return total + Int(transaction.amount)
            case .expense:
                return total - Int(transaction.amount)
            case .transfer:
                return total // Handle transfers separately if needed
            }
        }
        
        if totalAmount == 0 && hasTransactions {
            return "₹0" // Show ₹0 when there are transactions but they net to zero
        } else if totalAmount == 0 {
            return "" // Show nothing when there are no transactions
        } else if totalAmount > 0 {
            return "₹\(Int(totalAmount))"
        } else {
            return "₹\(Int(abs(totalAmount)))"
        }
    }
    
    // Color for the budget value
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
            return .orange // Use orange to indicate there are transactions but they net to zero
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                // 📅 Day number
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                // 💵 Budget value below date
                Text(budgetValue)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(budgetValueColor)
                
                // 🟠 Small dot indicator when there are transactions but net is zero
                if hasTransactions && budgetValue == "₹0" {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 4)
                } else {
                    // Empty space to maintain consistent layout
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 45, height: 55) // Slightly increased height to accommodate the dot
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: strokeWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 🎨 Style Computed Properties
    
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
        return Color.clear // Always transparent background
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .orange
        } else if hasTransactions {
            return .gray.opacity(0.6) // Slightly more visible border when there are transactions
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
            return 1.0 // Slightly thicker border when there are transactions
        } else {
            return 0.5
        }
    }
}

// MARK: - 👀 Preview
struct homeViewTab_preview: PreviewProvider {
    static var previews: some View {
        homeViewTab()
    }
}
