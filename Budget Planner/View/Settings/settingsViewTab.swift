//
//  settingsViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI
struct settingsViewTab: View {
    @StateObject private var currencyManager = CurrencyManager()
    @EnvironmentObject var appLockManager: AppLockManager
    @State private var showMailErrorAlert = false
    @Environment(\.openURL) var openURL
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // GENERAL Section
                        VStack(spacing: 0) {
                            HStack {
                                Text("GENERAL")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 1) {
                                NavigationLink(destination: ExportDataView()) {
                                    SettingsRow(
                                        icon: "arrow.up.doc",
                                        title: "Export Data",
                                        subtitle: nil
                                    )
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        }
                        
                        // ACCOUNT Section
                        VStack(spacing: 0) {
                            HStack {
                                Text("ACCOUNT")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 1) {
                                NavigationLink(destination: AccountsView()) {
                                    SettingsRow(
                                        icon: "creditcard",
                                        title: "Accounts",
                                        subtitle: "Number of accounts"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: CurrencyChangeView(currencyManager: currencyManager)) {
                                    SettingsRow(
                                        icon: "dollarsign.circle",
                                        title: "Currency",
                                        subtitle: "USD"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: CategoriesView()) {
                                    SettingsRow(
                                        icon: "square.grid.2x2",
                                        title: "Categories",
                                        subtitle: "Manage Categories"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: themeSettings()) {
                                    SettingsRow(
                                        icon: "circle.lefthalf.filled",
                                        title: "Theme",
                                        subtitle: "Selected Theme"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: AppLockView().environmentObject(appLockManager)) {
                                    SettingsRow(
                                        icon: "checkmark.shield",
                                        title: "App Lock",
                                        subtitle: getLockStatusText()
                                    )
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        }
                        
                        // SUPPORT Section
                        VStack(spacing: 0) {
                            HStack {
                                Text("SUPPORT")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 1) {
                                Button {
                                    openSupportEmail()
                                } label: {
                                    SettingsRow(
                                        icon: "headphones",
                                        title: "Help & Support",
                                        subtitle: nil
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Link(destination: URL(string: "https://www.freeprivacypolicy.com/live/dc173f25-99d8-4dfd-88ec-39adf553fb9d")!) {
                                    SettingsRow(
                                        icon: "info.circle",
                                        title: "Privacy Policy",
                                        subtitle: nil
                                    )
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        }
                        
                        // Version
                        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text("Version: \(appVersion)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .alert("Mail Not Available", isPresented: $showMailErrorAlert) {
                Button("Copy Email") {
                    UIPasteboard.general.string = "info@unikwork.com"
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Mail app is not configured. Email address 'info@unikwork.com' has been copied to clipboard.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func getLockStatusText() -> String {
            if appLockManager.isPasswordEnabled && appLockManager.isFaceIDEnabled {
                return "Password & Face ID"
            } else if appLockManager.isPasswordEnabled {
                return "Password Only"
            } else {
                return "Disabled"
            }
        }
        private func openSupportEmail() {
            guard let emailURL = URL(string: "mailto:info@unikwork.com?subject=Budget%20Planner%20Support") else {
                showMailErrorAlert = true
                return
            }
            if UIApplication.shared.canOpenURL(emailURL) {
                openURL(emailURL) { accepted in
                    if !accepted {
                        showMailErrorAlert = true
                    }
                }
            } else {
                showMailErrorAlert = true
            }
        }
    }
    struct SettingsRow: View {
        let icon: String
        let title: String
        let subtitle: String?
        var body: some View {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        settingsViewTab()
            .environmentObject(AppLockManager())
    }
}











