//
//  currencyChangeView.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct currencyChangeView: View {
    @ObservedObject private var currencyManager = CurrencyManager()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @State private var selectedCurrency: Currency?
    
    // Add initializer to accept currencyManager
    init(currencyManager: CurrencyManager) {
        self.currencyManager = currencyManager
    }
    
    // Convenience initializer for previews
    init() {
        self.currencyManager = CurrencyManager()
    }
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencyManager.currencies
        } else {
            return currencyManager.currencies.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack {
            
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 20){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text("Currency")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal,20)
            .padding(.top)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search currency", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal,16)
            .padding(.top, 20)
            
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
                        )
                    }
                }
            }
            .padding()
            
            // Save Button
            Button(action: {
                if let selected = selectedCurrency {
                    currencyManager.selectedCurrency = selected
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
        .navigationBarHidden(true)
        .onAppear {
            selectedCurrency = currencyManager.selectedCurrency
        }
    }
}

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

struct currencyChangeView_Previews: PreviewProvider {
    static var previews: some View {
        currencyChangeView()
    }
}
