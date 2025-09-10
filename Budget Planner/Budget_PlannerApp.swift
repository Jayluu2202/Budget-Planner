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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appLockManager.isLocked {
                    PasswordUnlockView(appLockManager: appLockManager)
                } else {
                    tabView()
                        .environmentObject(appLockManager)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background, .inactive:
                    appLockManager.lockApp()
                case .active:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
