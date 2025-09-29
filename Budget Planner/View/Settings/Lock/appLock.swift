//
//  appLock.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI
import UIKit
struct AppLockView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var appLockManager = AppLockManager()
    @State private var showPasswordSetup = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Custom Back Button
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("App Lock")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Secure your app with authentication methods")
                    .font(.system(size: 14.5))
                    .foregroundColor(.secondary)
                
                // Password Lock Row
                HStack(spacing: 15) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Password Lock")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(appLockManager.isPasswordEnabled ? "Enabled" : "Not Enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { appLockManager.isPasswordEnabled },
                        set: { newValue in
                            if newValue {
                                showPasswordSetup = true
                            } else {
                                showDisablePasswordAlert()
                            }
                        }
                    ))
                    .labelsHidden()
                }
                .frame(height: 50)
                
                // FaceID Row
                HStack(spacing: 15) {
                    Image(systemName: "faceid")
                        .font(.system(size: 25))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FaceID")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(appLockManager.isFaceIDEnabled ? "Enabled" : "Not Enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { appLockManager.isFaceIDEnabled },
                        set: { newValue in
                            // Check if password is enabled first
                            if !appLockManager.isPasswordEnabled && newValue {
                                showFaceIDRequiresPasswordAlert()
                            } else {
                                appLockManager.setFaceIDEnabled(newValue)
                            }
                        }
                    ))
                    .labelsHidden()
                    .disabled(!appLockManager.isPasswordEnabled) // Disable if password is not enabled
                    .opacity(appLockManager.isPasswordEnabled ? 1.0 : 0.5) // Visual indication
                }
                .frame(height: 50)
                
            }
            .navigationBarHidden(true)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary, lineWidth: 1)
                    
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
            
            // No Security Enabled Warning
            if !appLockManager.isPasswordEnabled && !appLockManager.isFaceIDEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No Security Enabled")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Your app is not protected. Enable password or biometric authentication to secure your data.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)
            }
            
            // FaceID Requires Password Info
            if appLockManager.isPasswordEnabled && !appLockManager.isFaceIDEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enhanced Security Available")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Enable Face ID for faster authentication. Password lock is required as a backup method.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .onAppear{
            hideTabBarLegacy()
        }
        .onDisappear{
            showTabBarLegacy()
        }
        .sheet(isPresented: $showPasswordSetup) {
            PasswordKeyPadView(appLockManager: appLockManager)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            if alertMessage.contains("disable password") {
                Button("Cancel") { }
                Button("Disable") {
                    appLockManager.removePassword()
                    // Also disable FaceID when password is disabled
                    appLockManager.setFaceIDEnabled(false)
                }
            } else {
                Button("OK") { }
            }
        }
    }
    
    private func showDisablePasswordAlert() {
        alertMessage = "Are you sure you want to disable password protection? This will also disable Face ID."
        showAlert = true
    }
    
    private func showFaceIDRequiresPasswordAlert() {
        alertMessage = "Face ID requires password protection to be enabled first. Please enable password lock before using Face ID."
        showAlert = true
    }
}

extension AppLockView {
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
struct AppLockView_Previews: PreviewProvider {
    static var previews: some View {
        AppLockView()
    }
}
