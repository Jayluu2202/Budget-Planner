//
//  AddTransactionDetails.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct AddTransactionDetails: View {
    @Environment(\.dismiss) var dismiss
    // 1️⃣ Create an enum for cleaner code
    enum TransactionType: String, CaseIterable {
        case income = "Income"
        case expense = "Expense"
        case transfer = "Transfer"
    }
    
    // 2️⃣ Track selected type
    @State private var selectedType: TransactionType = .income
    @State private var transactionDate = Date()
    @State private var amount = ""
    @State private var description = ""
    @State private var repeatTransation = false
    
    let accounts = ["Cash", "Bank", "Credit Card"]
    let categories = ["Salary", "Food", "Shopping", "Transport"]
    
    @State private var selectedAccount = "Cash"
    @State private var selectedCategories = "Salary"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented Picker
                Picker("Transaction Type", selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                DatePicker(
                    "",
                    selection: $transactionDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                    .labelsHidden()
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                    
                VStack{
                    TextField("Amount", text: $amount)
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .cornerRadius(10)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                }
                
                Spacer()
                
                VStack(spacing: 16){
                    HStack{
                        VStack(alignment: .leading){
                            Text("Account")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Menu{
                                ForEach(accounts, id: \.self){ account in
                                    Button(account){
                                        selectedAccount = account
                                    }
                                }
                            } label: {
                                Text(selectedAccount)
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("Category")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button(category) {
                                        selectedCategories = category
                                    }
                                }
                            } label: {
                                Text(selectedCategories)
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }.padding(.horizontal)
                    
                    Divider()
                    // Repeat Transaction Toggle
                    Toggle(isOn: $repeatTransation) {
                        Text("Repeat Transaction")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        
                    }){
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}


struct AddTransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionDetails()
    }
}
