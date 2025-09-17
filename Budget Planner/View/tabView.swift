//
//  tabView.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct tabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var appLockManager: AppLockManager
    @StateObject private var transactionManager = TransactionManager()
    @StateObject private var budgetManager = BudgetManager()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // Selected text attributes
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        
        // Unselected text attributes
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab){
            homeViewTab()
                .tabItem{
                    Image(selectedTab == 0 ? "HomeFilled" : "HomeOutline")
                    Text("Home")
                }.tag(0)
            transactionViewTab()
                .tabItem{
                    Image(selectedTab == 1 ? "TransactionFilled" : "TransactionOutline")
                    Text("Transactions")
                }.tag(1)
            ReportViewTab(transactionManager: transactionManager, budgetManager: budgetManager)
                .tabItem{
                    Image(selectedTab == 2 ? "ReportFilled" : "ReportOutline")
                    Text("Report")
                }.tag(2)
            budgetViewTab()
                .tabItem{
                    Image(selectedTab == 3 ? "BudgetFilled" : "BudgetOutline")
                    Text("Budget")
                }.tag(3)
            settingsViewTab()
                .tabItem{
                    Image(selectedTab == 4 ? "SettingsFilled" : "SettingsOutline")
                    Text("Settings")
                }.tag(4)
        }
        .tint(.black)
        .environmentObject(appLockManager) // Pass the appLockManager to child views
    }
}

struct tabView_Previews: PreviewProvider {
    static var previews: some View {
        tabView()
            .environmentObject(AppLockManager()) // Add this for preview
            .previewInterfaceOrientation(.portrait)
    }
}
