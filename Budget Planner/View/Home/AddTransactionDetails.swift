//
//  AddTransactionDetails.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI
import ContactsUI

struct AddTransactionDetails: View {
    @Environment(\.dismiss) var dismiss
    
    // 🔄 Accept TransactionManager as parameter instead of creating new instance
    @ObservedObject var transactionManager: TransactionManager
    
    @State private var selectedType: TransactionType = .income
    @State private var transactionDate = Date()
    @State private var amount = ""
    @State private var description = ""
    @State private var repeatTransation = false
    
    @StateObject private var accountStore = AccountStore()
    @StateObject private var categoryStore = CategoryStore()
    @StateObject private var currencyStore = CurrencyManager()
    
    @State private var selectedAccount: Account? = nil
    @State private var selectedCategories: Category? = nil
    @State private var selectedSenderAccount: Account? = nil
    @State private var selectedReceiverAccount: Account? = nil
    @State private var currencyName: Currency? = nil
    
    // Contact picker states
    @State private var showingContactPicker = false
    @State private var selectedContact: String? = nil
    @State private var isSelectingSender = true // Track which contact we're selecting for
    
    // Alert states
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented Picker with proper spacing
                VStack(spacing: 16) {
                    Picker("Transaction Type", selection: $selectedType) {
                        ForEach([TransactionType.income, TransactionType.expense, TransactionType.transfer], id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    DatePicker(
                        "",
                        selection: $transactionDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 8)
                
                if selectedType == .transfer {
                    // Transfer UI
                    VStack(spacing: 20) {
                        // Amount Input
                        HStack {
                            TextField("0", text: $amount)
                                .font(.largeTitle)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                            Text("INR")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        TextField("Add a note", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        // Contact Selection Buttons
                        HStack(spacing: 16) {
                            // Sender Button - Opens Contacts
                            Button(action: {
                                isSelectingSender = true
                                showingContactPicker = true
                            }) {
                                Text("Sender")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.black)
                                    .cornerRadius(8)
                            }
                            
                            // Receiver Button - Opens Contacts
                            Button(action: {
                                isSelectingSender = false
                                showingContactPicker = true
                            }) {
                                Text("Receiver")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.black)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Simple Account List
                        VStack(spacing: 8) {
                            ForEach(accountStore.accounts) { account in
                                Button(action: {
                                    // Simple toggle selection
                                    if selectedSenderAccount?.id == account.id {
                                        selectedSenderAccount = nil
                                    } else if selectedReceiverAccount?.id == account.id {
                                        selectedReceiverAccount = nil
                                    } else {
                                        // Assign to sender or receiver based on which was last selected
                                        if isSelectingSender {
                                            selectedSenderAccount = account
                                        } else {
                                            selectedReceiverAccount = account
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(account.emoji)
                                            .font(.title2)
                                        Text(account.name)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        
                                        // Simple checkmark for selected accounts
                                        if selectedSenderAccount?.id == account.id || selectedReceiverAccount?.id == account.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.black)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                (selectedSenderAccount?.id == account.id || selectedReceiverAccount?.id == account.id) ? Color.black : Color.gray.opacity(0.3),
                                                lineWidth: 1
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color(.systemGray6))
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Existing Income/Expense UI
                    VStack(spacing: 16) {
                        // Amount Input for Income/Expense
                        HStack {
                            TextField("0", text: $amount)
                                .font(.largeTitle)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                            Text("INR")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        TextField("Add a note", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading){
                                Text("Account")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                if accountStore.accounts.isEmpty {
                                    Text("No accounts available")
                                } else {
                                    Menu {
                                        ForEach(accountStore.accounts) { account in
                                            Button("\(account.emoji) \(account.name)") {
                                                selectedAccount = account
                                            }
                                        }
                                    } label: {
                                        Text(selectedAccount.map { "\($0.emoji) \($0.name)" } ?? "Select Account")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing){
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Menu {
                                    ForEach(categoryStore.getCategories(for: selectedType == .income ? .income : .expense)) { category in
                                        Button("\(category.emoji) \(category.name)") {
                                            selectedCategories = category
                                        }
                                    }
                                } label: {
                                    Text(selectedCategories.map {
                                        "\($0.emoji) \($0.name)"} ??
                                         "Select Category")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        Toggle(isOn: $repeatTransation) {
                            Text("Repeat Transaction")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    saveTransaction()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker(selectedContact: $selectedContact)
            }
            .alert("Validation Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Save Transaction Function
    private func saveTransaction() {
        // Validate input
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        guard let account = selectedAccount else {
            alertMessage = "Please select an account"
            showingAlert = true
            return
        }
        
        guard let category = selectedCategories else {
            alertMessage = "Please select a category"
            showingAlert = true
            return
        }
        
        // Convert Category to TransactionCategory for compatibility
        let transactionCategory = TransactionCategory(
            id: category.id,
            name: category.name,
            emoji: category.emoji,
            type: selectedType == .income ? .income : .expense
        )
        
        // Convert local TransactionType to global TransactionType
        let globalTransactionType: TransactionType
        switch selectedType {
        case .income:
            globalTransactionType = .income
        case .expense:
            globalTransactionType = .expense
        case .transfer:
            globalTransactionType = .transfer
        }
        
        // Create transaction
        let transaction = Transaction(
            type: globalTransactionType,
            amount: amountValue,
            description: description.isEmpty ? "No description" : description,
            date: transactionDate,
            account: account,
            category: transactionCategory,
            isRepeating: repeatTransation
        )
        
        // Save transaction using the passed transactionManager instance
        transactionManager.addTransaction(transaction)
        
        // Clear form and dismiss
        amount = ""
        description = ""
        selectedAccount = nil
        selectedCategories = nil
        dismiss()
    }
}

// Contact Picker View
struct ContactPicker: UIViewControllerRepresentable {
    @Binding var selectedContact: String?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPicker
        
        init(_ parent: ContactPicker) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            parent.selectedContact = formatter.string(from: contact) ?? "\(contact.givenName) \(contact.familyName)"
            parent.dismiss()
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.dismiss()
        }
    }
}

struct AddTransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionDetails(transactionManager: TransactionManager())
    }
}
