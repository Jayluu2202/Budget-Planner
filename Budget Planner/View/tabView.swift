//
//  tabView.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct tabView: View {
    var body: some View {
        TabView{
            homeViewTab()
                .tabItem{
                    Image("HomeFilled")
                    Text("Home")
                }.tag(0)
            transactionViewTab()
                .tabItem{
                    Image("TransactionFilled")
                    Text("Transactions")
                }.tag(1)
            reportViewTab()
                .tabItem{
                    Image("ReportFilled")
                    Text("Report")
                }.tag(2)
            budgetViewTab()
                .tabItem{
                    Image("BudgetFilled")
                    Text("Budget")
                }.tag(3)
            settingsViewTab()
                .tabItem{
                    Image("SettingsFilled")
                    Text("Settings")
                }.tag(4)
        }
    }
}

struct tabView_Previews: PreviewProvider {
    static var previews: some View {
        tabView()
            .previewInterfaceOrientation(.portrait)
    }
}
