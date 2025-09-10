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
    
    var body: some View {
        VStack(spacing: 0) {
            // 👋 Greeting Section
            buildGreetingSection()
            
            ZStack(alignment: .bottomTrailing) { // 👈 Floating button positioning
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 📆 Calendar Section
                        buildCalendarSection()
                        
                        // 📊 Transactions Section
                        buildTransactionsSection()
                    }
                    .padding(.top, 8)
                }
                
                // ➕ Floating Add Button
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
                .sheet(isPresented: $showAddScreen) {
                    AddTransactionDetails()
                }
                .ignoresSafeArea()
            }
        }
        .padding()
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
            
            Button(action: handleWealthButtonTap) {
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
                selectedDate: $selectedDate
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
            
            // 📝 Sample Transactions
            ForEach(0..<5, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sample Transaction \(index + 1)")
                        .font(.body)
                    Text("$\((index + 1) * 25).00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Divider()
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
                        selectedDate: $selectedDate
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
    
    // 💰 Sample budget values for each day
    private var budgetValue: String {
        let day = Calendar.current.component(.day, from: date)
        let sampleValues = ["$125", "$89", "$234", "$67", "$145", "$78", "$190"]
        return sampleValues[day % sampleValues.count]
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
                    .foregroundColor(.secondary)
            }
            .frame(width: 45, height: 50)
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
        return Color.clear // 🔄 Always transparent background
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .orange
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        if isSelected {
            return 2.0
        } else if isToday {
            return 1.5
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
