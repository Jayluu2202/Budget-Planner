//
//  settingsViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct settingsViewTab: View {
    @StateObject private var currencyManager = CurrencyManager()
    @EnvironmentObject var appLockManager: AppLockManager // Add this line
    @State private var showCurrencyPicker = false
    @State private var showMailErrorAlert = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: ExportDataView()) {
                        hStackFunc(image: "arrow.up.doc", title: "Export Data", showSubtitle: false, subtitle: "")
                    }
                } header: {
                    Text("General")
                }
                
                Section {
                    NavigationLink(destination: AccountsView()){
                        hStackFunc(image: "creditcard", title: "Accounts", showSubtitle: true, subtitle: "Number of accounts")
                        
                    }
                    
                    NavigationLink(destination: currencyChangeView(currencyManager: currencyManager)){
                        hStackFunc(image: "dollarsign.circle", title: "Currency", showSubtitle: true, subtitle: currencyManager.selectedCurrency.code)
                    }
                    
                    NavigationLink(destination: CategoriesView()){
                        hStackFunc(image: "square.grid.2x2", title: "Categories", showSubtitle: true, subtitle: "Manage Categories")
                    }
                    
                    NavigationLink(destination: themeSettings()){
                        hStackFunc(image: "circle.lefthalf.filled", title: "Theme", showSubtitle: true, subtitle: "Selected Theme")
                    }
                    
                    // Updated App Lock Navigation Link
                    NavigationLink(destination: AppLockView().environmentObject(appLockManager)){
                        hStackFunc(image: "checkmark.shield", title: "App Lock", showSubtitle: true, subtitle: getLockStatusText())
                    }
                    
                } header: {
                    Text("Account")
                }
                
                Section {
                    Button {
                        openSupportEmail()
                    } label: {
                        hStackFunc(image: "headphones", title: "Help & Support", showSubtitle: false, subtitle: "")
                            .foregroundColor(.black)
                    }
                    
                    Link(destination: URL(string: "https://www.freeprivacypolicy.com/live/dc173f25-99d8-4dfd-88ec-39adf553fb9d")!) {
                        hStackFunc(image: "info.circle", title: "Privacy Policy", showSubtitle: false, subtitle: "")
                            .foregroundColor(.black)
                    }
                    
                } header: {
                    Text("Support")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Setting")
            .alert("Mail Not Available", isPresented: $showMailErrorAlert) {
                Button("Copy Email") {
                    UIPasteboard.general.string = "info@unikwork.com"
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Mail app is not configured. Email address 'info@unikwork.com' has been copied to clipboard.")
            }
        }
    }
    
    // Add this new function
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

        
        // Check if the URL can be opened
        if UIApplication.shared.canOpenURL(emailURL) {
            openURL(emailURL) { accepted in
                if !accepted {
                    // If opening failed, show alert
                    showMailErrorAlert = true
                }
            }
        } else {
            // If mail app is not available, show alert
            showMailErrorAlert = true
        }
    }
    
    func hStackFunc(image: String, title: String, showSubtitle: Bool, subtitle: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
            
            VStack(spacing: 2) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showSubtitle{
                    Text(subtitle)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(height: 50)
    }
}

struct settingsViewTab_preview: PreviewProvider {
    static var previews: some View {
        settingsViewTab()
            .environmentObject(AppLockManager()) // Add this line for preview
    }
}
