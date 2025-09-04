//
//  homeViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct homeViewTab: View {
    @State private var currentDate = Date()
    var body: some View {
        VStack{
            HStack{
                Text("Hey! Greetings")
                    .font(.headline)
                Image("WaveHand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Spacer()
                Button(action: {
                    print("Money button Tapped")
                }){
                    Image("Wealth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
            }
            
            HStack{
                Button(action: previousMonth){
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
                Text(monthYearString)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Button(action: nextMonth){
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black)
                }
            }
            Spacer()
            
            
        }.padding()
        
    }
    private var monthYearString: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func previousMonth(){
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    private func nextMonth(){
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

struct HomeViewTab_Previews: PreviewProvider {
    static var previews: some View {
        homeViewTab()
    }
}
