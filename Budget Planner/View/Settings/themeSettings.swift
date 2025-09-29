//
//  themeSettings.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI
import UIKit
struct themeSettings: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
//    @Binding var selectedTheme : String
//    @AppStorage("selectedTheme") var selectedTheme: String = "System"
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 20){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Theme Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                
                Text("Choose your preferred theme mode")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
            
            // Options
            VStack(spacing: 12) {
                themeOption(title: "Light", systemImage: "light", selectedTheme: $themeManager.selectedTheme)
                themeOption(title: "Dark", systemImage: "dark", selectedTheme: $themeManager.selectedTheme)
                themeOption(title: "System", systemImage: "system", selectedTheme: $themeManager.selectedTheme)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .preferredColorScheme(
            themeManager.colorScheme
        )
        .onAppear{
            hideTabBarLegacy()
        }
        .onDisappear{
            showTabBarLegacy()
        }
        .navigationBarHidden(true)
    }
}
extension themeSettings {
    // Updated method for hiding tab bar
    private func hideTabBarLegacy() {
        DispatchQueue.main.async {
            // Method 1: Using scene-based approach (iOS 13+)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = true
                } else {
                    // Method 2: Navigate through view hierarchy
                    findAndHideTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    private func showTabBarLegacy() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = false
                } else {
                    findAndShowTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    // Recursive method to find tab bar controller
    private func findAndHideTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = true
        } else if let navigationController = vc as? UINavigationController {
            findAndHideTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndHideTabBar(in: child)
            }
        }
    }
    
    private func findAndShowTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = false
        } else if let navigationController = vc as? UINavigationController {
            findAndShowTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndShowTabBar(in: child)
            }
        }
    }
}
// MARK: - Reusable Option Row
struct themeOption: View {
    let title: String
    let systemImage: String
    @Binding var selectedTheme: String
    
    @Environment(\.colorScheme) var colorScheme
        
    var body: some View {
        Button(action: {
            selectedTheme = title
            print("Checking theme Selected: \(selectedTheme)")
        }) {
            HStack {
                Image(systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.body)
                Spacer()
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedTheme == title ? Color.primary : Color.secondary.opacity(0.5), lineWidth: selectedTheme == title ? 1.5 : 1)
                
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct themeSettings_Previews: PreviewProvider {
    static var previews: some View {
        themeSettings()
            .environmentObject(ThemeManager())
    }
}
