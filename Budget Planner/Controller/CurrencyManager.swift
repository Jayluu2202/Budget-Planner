//
//  CurrencyManager.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import Foundation

// MARK: - Controller/Manager
class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: Currency = Currency(code: "USD", name: "US Dollar", symbol: "$")
    
    // Access to all currencies from the data source
    let currencies: [Currency] = CurrencyData.allCurrencies
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let selectedCurrencyCode = "selectedCurrencyCode"
        static let selectedCurrencyName = "selectedCurrencyName"
        static let selectedCurrencySymbol = "selectedCurrencySymbol"
    }
    
    // MARK: - Initialization
    init() {
        loadSavedCurrency()
    }
    
    // MARK: - Public Methods
    func selectCurrency(_ currency: Currency) {
        selectedCurrency = currency
        saveCurrencyToUserDefaults(currency)
    }
    
    func filterCurrencies(by searchText: String) -> [Currency] {
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadSavedCurrency() {
        guard let savedCode = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCurrencyCode),
              let savedName = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCurrencyName),
              let savedSymbol = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCurrencySymbol) else {
            return
        }
        
        selectedCurrency = Currency(code: savedCode, name: savedName, symbol: savedSymbol)
    }
    
    private func saveCurrencyToUserDefaults(_ currency: Currency) {
        UserDefaults.standard.set(currency.code, forKey: UserDefaultsKeys.selectedCurrencyCode)
        UserDefaults.standard.set(currency.name, forKey: UserDefaultsKeys.selectedCurrencyName)
        UserDefaults.standard.set(currency.symbol, forKey: UserDefaultsKeys.selectedCurrencySymbol)
    }
}
