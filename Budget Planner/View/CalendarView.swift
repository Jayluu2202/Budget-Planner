//
//  CalendarView.swift
//  Budget Planner
//
//  Created by Admin on 04/09/25.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @Binding var currentDate: Date
    
    var body: some View {
        VStack{
            HStack{
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self){ day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                }
            }.padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8){
                ForEach(getAllDaysInMonth(), id: \.self){ date in
                    if let date = date{
                        DayView(date: date, currentMonth: currentDate)
                    }else{
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    private func getAllDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: .currentDate)
    }
}
