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
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showMailErrorAlert = false
    
    @State var currencySelected: Currency?
    
//    @State var selectedState : String = "Light"
    
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
                    .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // GENERAL Section
                        VStack(spacing: 0) {
                            HStack {
                                Text("GENERAL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 1) {
                                NavigationLink(destination: ExportDataView()) {
                                    SettingsRow(
                                        icon: "import-export",
                                        title: "Export Data",
                                        subtitle: nil
                                    )
                                }
                            }
                            .frame(height: 60)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.4), lineWidth: 2)
                            )
                            .padding(.horizontal, 20)
                            
                        }
                        
                        // ACCOUNT Section
                        VStack(spacing: 0) {
                            HStack {
                                Text("ACCOUNT")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 1) {
                                NavigationLink(destination: AccountsView()) {
                                    SettingsRow(
                                        icon: "bank-account",
                                        title: "Accounts",
                                        subtitle: "Number of accounts"
                                    )
                                }
                                .frame(height: 60)
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: CurrencyChangeView(currencyManager: currencyManager, selectedCurrency: $currencySelected)) {
                                    SettingsRow(
                                        icon: "coin",
                                        title: "Currency",
                                        subtitle: currencyManager.selectedCurrency.code
                                    )
                                }
                                .frame(height: 60)
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: CategoriesView()) {
                                    SettingsRow(
                                        icon: "category",
                                        title: "Categories",
                                        subtitle: "Manage Categories"
                                    )
                                }
                                .frame(height: 60)
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: themeSettings().environmentObject(themeManager)) {
                                    SettingsRow(
                                        icon: "contrast",
                                        title: "Theme",
                                        subtitle: themeManager.selectedTheme // Change this line
                                    )
                                }
                                .frame(height: 60)
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: AppLockView().environmentObject(appLockManager)) {
                                    SettingsRow(
                                        icon: "security",
                                        title: "App Lock",
                                        subtitle: getLockStatusText()
                                    )
                                }
                                .frame(height: 60)
                            }
                            
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.4), lineWidth: 2)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // SUPPORT Section
                        VStack(spacing: 0) {
                            HStack {
                                Text("SUPPORT")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
                                        icon: "support",
                                        title: "Help & Support",
                                        subtitle: nil
                                    )
                                }
                                .frame(height: 60)
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Link(destination: URL(string: "https://www.freeprivacypolicy.com/live/dc173f25-99d8-4dfd-88ec-39adf553fb9d")!) {
                                    SettingsRow(
                                        icon: "info",
                                        title: "Privacy Policy",
                                        subtitle: nil
                                    )
                                }
                                .frame(height: 60)
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.4), lineWidth: 2)
                            )
                            .padding(.horizontal, 20)
                            
                        }
                                                
                        
                        // Version
                        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text("Version: \(appVersion)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .preferredColorScheme(themeManager.colorScheme)
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
                Image(icon)
                    .resizable()
                    .scaledToFit()
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
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }

//// Preview
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        settingsViewTab(currencySelected: .constant(Currency(code: "USD", name: "US Dollar", symbol: "$")))
//            .environmentObject(AppLockManager())
//    }
//}
//

