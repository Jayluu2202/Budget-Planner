//
//  Budget_PlannerApp.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

@main
struct Budget_PlannerApp: App {
    @StateObject private var appLockManager = AppLockManager()
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var transactionManager = TransactionManager.shared
    @StateObject private var currencyManager = CurrencyManager()
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingManager.hasCompletedOnboarding {
                    NavigationView {
                        OnboardingView(onboardingManager: onboardingManager)
                    }
                    .navigationBarHidden(true)
                } else if appLockManager.isLocked {
                    // Show lock screen for returning users
                    PasswordUnlockView(appLockManager: appLockManager)
                } else {
                    // Show main app
                    tabView()
                        .environmentObject(appLockManager)
                        .environmentObject(transactionManager)
                        .environmentObject(currencyManager)
                        .environmentObject(themeManager)
                }
            }
            .preferredColorScheme(themeManager.colorScheme)
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background, .inactive:
                    // Only lock app if onboarding is completed
                    if onboardingManager.hasCompletedOnboarding {
                        appLockManager.lockApp()
                    }
                case .active:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}



