//
//  homeViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct homeViewTab: View {
    // Step 1: Add state variables for calendar functionality
    @State private var currentDate = Date()
    
    var body: some View {
        VStack {
            // Your existing greeting section
            HStack {
                Text("Hey! Greetings")
                    .font(.headline)
                Image("WaveHand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Spacer()
                Button(action: {
                    print("Money button Tapped")
                }) {
                    Image("Wealth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
            }
            
            // Step 2: Month navigation header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        
                }.padding(.trailing, 60)
                
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 200)
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                        
                }.padding(.leading, 60)
            }
            .padding(.vertical)
            
            // Step 3: Add the calendar view
            CalendarView(currentDate: $currentDate)
            
            Spacer()
        }
        .padding()
    }
    
    // Helper computed property to format month and year
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    // Navigation functions
    private func previousMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

// Step 4: Create the calendar view component
struct CalendarView: View {
    @Binding var currentDate: Date
    
    var body: some View {
        VStack(spacing: 0) {
            // Days of the week header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getAllDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayView(date: date, currentMonth: currentDate)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    // Function to get all days in the current month (including empty spaces)
    private func getAllDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        var days: [Date?] = []
        
        // Add empty spaces for days before the first day of the month
        let startWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        for _ in 0..<startWeekday {
            days.append(nil)
        }
        
        // Add all days of the current month
        var currentDay = startOfMonth
        while currentDay < endOfMonth {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
        }
        
        return days
    }
}

// Step 5: Create individual day view
struct DayView: View {
    let date: Date
    let currentMonth: Date
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isToday ? Color.blue : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
}

struct HomeViewTab_Previews: PreviewProvider {
    static var previews: some View {
        homeViewTab()
    }
}
