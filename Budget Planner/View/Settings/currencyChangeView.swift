//
//  CurrencyChangeView.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI
import UIKit
// MARK: - Main Currency Selection View
struct CurrencyChangeView: View {
    @ObservedObject private var currencyManager: CurrencyManager
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @Binding private var selectedCurrency: Currency?
    
    // MARK: - Initializers
    init(currencyManager: CurrencyManager, selectedCurrency: Binding<Currency?>) {
        self.currencyManager = currencyManager
        self._selectedCurrency = selectedCurrency
    }
    
    var filteredCurrency: [Currency] {
        currencyManager.filterCurrencies(by: searchText)
    }
    
    // MARK: - Computed Properties
    var filteredCurrencies: [Currency] {
        return currencyManager.filterCurrencies(by: searchText)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            headerView
            searchBarView
            currencyListView
            saveButton
        }
        .navigationBarHidden(true)
        .onAppear {
            selectedCurrency = currencyManager.selectedCurrency
            hideTabBarLegacy()
        }
        .onDisappear{
            showTabBarLegacy()
        }
    }
    
    // MARK: - View Components
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 20){
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("Select Currency")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top)
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search currency", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    private var currencyListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(filteredCurrencies, id: \.id) { currency in
                    CurrencyRowView(
                        currency: currency,
                        isSelected: selectedCurrency?.code == currency.code
                    ) {
                        selectedCurrency = currency
                    }
                    .padding(.horizontal)
                    .frame(height: 60)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedCurrency?.code == currency.code ? Color.black : Color(.systemGray6), lineWidth: 2)
                            .padding(.horizontal, 10)
                    )
                }
            }
        }
        .padding()
    }
    
    private var saveButton: some View {
        Button(action: {
            if let selected = selectedCurrency {
                currencyManager.selectCurrency(selected)
                dismiss()
            }
        }) {
            Text("Save")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .disabled(selectedCurrency == nil)
    }
}

extension CurrencyChangeView {
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
// MARK: - Currency Row Component View
struct CurrencyRowView: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(currency.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(currency.symbol)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//// MARK: - Preview
//struct CurrencyChangeView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyChangeView(currencyManager: CurrencyManager, selectedCurrency: $currencySelected)
//    }
//}
