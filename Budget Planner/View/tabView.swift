//
//  tabView.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct tabView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appLockManager: AppLockManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var transactionManager = TransactionManager()
    @StateObject private var budgetManager = BudgetManager()
    @StateObject private var currencyManager = CurrencyManager()
    @State var selectedCurrency: Currency?
    
    // Remove the init() method completely - this was causing the issue
    
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
            ReportViewTab(transactionManager: TransactionManager.shared, budgetManager: budgetManager)
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
        .tint(.primary)
        .onAppear {
            updateTabBarAppearance()
        }
        .onChange(of: themeManager.selectedTheme) { _ in
            // Update when theme changes
            updateTabBarAppearance()
        }
        .onChange(of: colorScheme) { _ in
            // Update when system color scheme changes (for System theme)
            updateTabBarAppearance()
        }
        .environmentObject(appLockManager)
        .environmentObject(currencyManager)
        .environmentObject(themeManager)
    }
    
    private func updateTabBarAppearance() {
        DispatchQueue.main.async {
            // Get the current effective color scheme
            let effectiveColorScheme: ColorScheme = {
                switch themeManager.selectedTheme {
                case "Light":
                    return .light
                case "Dark":
                    return .dark
                default: // System
                    return colorScheme
                }
            }()
            
            // Find and update the actual tab bar instance
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                updateTabBar(in: window.rootViewController, colorScheme: effectiveColorScheme)
            }
        }
    }
    
    private func updateTabBar(in viewController: UIViewController?, colorScheme: ColorScheme) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colorScheme == .dark ? UIColor.black : UIColor.white
            
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.label
            ]
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.secondaryLabel
            ]
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            
            // Update the actual tab bar instance
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
            
        } else if let navigationController = vc as? UINavigationController {
            updateTabBar(in: navigationController.topViewController, colorScheme: colorScheme)
        } else {
            for child in vc.children {
                updateTabBar(in: child, colorScheme: colorScheme)
            }
        }
    }
}

struct tabView_Previews: PreviewProvider {
    static var previews: some View {
        tabView()
            .environmentObject(AppLockManager())
            .environmentObject(CurrencyManager())
            .environmentObject(ThemeManager())
            .previewInterfaceOrientation(.portrait)
    }
}
