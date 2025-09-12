//
//  AddBudgetView.swift
//  Budget Planner
//
//  Created by Assistant on 11/09/25.
//

import SwiftUI

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var budgetManager: BudgetManager
    @ObservedObject var transactionManager: TransactionManager
    
    @State private var selectedCategory: TransactionCategory?
    @State private var budgetAmount: String = ""
    @State private var description: String = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var showCategoryPicker = false
    
    // Slider state for amount
    @State private var sliderValue: Double = 1000
    @State private var isUsingSlider: Bool = true
    
    private var expenseCategories: [TransactionCategory] {
        return transactionManager.categories.filter { $0.type == .expense }
    }
    
    private var isFormValid: Bool {
        return selectedCategory != nil &&
               (budgetAmount.isEmpty ? sliderValue > 0 : Double(budgetAmount) ?? 0 > 0)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Category Selection
                    buildCategorySection()
                    
                    // Budget Amount Section
                    buildBudgetAmountSection()
                    
                    // Date Range Section
                    buildDateRangeSection()
                    
                    // Description Section
                    buildDescriptionSection()
                    
                    // Summary Section
                    if isFormValid {
                        buildSummarySection()
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("Create Budget")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                createBudgetButton
            }
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildCategorySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Category")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button(action: {
                showCategoryPicker = true
            }) {
                HStack {
                    if let category = selectedCategory {
                        Text(category.emoji)
                            .font(.title2)
                        Text(category.name)
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        Text("🛍️")
                            .font(.title2)
                        Text("Select Category")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    categories: expenseCategories,
                    selectedCategory: $selectedCategory,
                    isPresented: $showCategoryPicker
                )
            }
        }
    }
    
    @ViewBuilder
    private func buildBudgetAmountSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Amount")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Amount input methods toggle
            HStack {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isUsingSlider = true
                        budgetAmount = ""
                    }
                }) {
                    Text("Slider")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isUsingSlider ? Color.black : Color(.systemGray5))
                        .foregroundColor(isUsingSlider ? .white : .secondary)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        isUsingSlider = false
                        sliderValue = 1000
                    }
                }) {
                    Text("Manual")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(!isUsingSlider ? Color.black : Color(.systemGray5))
                        .foregroundColor(!isUsingSlider ? .white : .secondary)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            if isUsingSlider {
                // Slider input
                VStack(spacing: 16) {
                    Slider(value: $sliderValue, in: 100...50000, step: 100)
                        .accentColor(.black)
                    
                    Text("₹\(Int(sliderValue))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
            } else {
                // Manual input
                HStack {
                    Text("₹")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    TextField("1000", text: $budgetAmount)
                        .font(.title2)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func buildDateRangeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Period")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("End Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date])
                        .datePickerStyle(.compact)
                }
            }
            .padding(.top, 4)
            
            // Period summary
            let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            Text("Duration: \(days) days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func buildDescriptionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $description)
                .frame(minHeight: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: description.isEmpty ? 0 : 1)
                )
                .overlay(
                    VStack {
                        HStack {
                            if description.isEmpty {
                                Text("Add description...")
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 16)
                                    .padding(.top, 16)
                            }
                            Spacer()
                        }
                        Spacer()
                    },
                    alignment: .topLeading
                )
        }
    }
    
    @ViewBuilder
    private func buildSummarySection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Summary")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Category:")
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 8) {
                        Text(selectedCategory?.emoji ?? "")
                        Text(selectedCategory?.name ?? "")
                            .fontWeight(.medium)
                    }
                }
                
                HStack {
                    Text("Budget Amount:")
                        .foregroundColor(.secondary)
                    Spacer()
                    let amount = isUsingSlider ? sliderValue : (Double(budgetAmount) ?? 0)
                    Text("₹\(Int(amount))")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                HStack {
                    Text("Duration:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(days) days")
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var createBudgetButton: some View {
        Button(action: createBudget) {
            Text("Create Budget")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isFormValid ? Color.black : Color(.systemGray4))
                .cornerRadius(12)
        }
        .disabled(!isFormValid)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func createBudget() {
        guard let category = selectedCategory else { return }
        
        let amount = isUsingSlider ? sliderValue : (Double(budgetAmount) ?? 0)
        guard amount > 0 else { return }
        
        let newBudget = Budget(
            category: category,
            budgetAmount: amount,
            description: description.isEmpty ? "Budget for \(category.name)" : description,
            startDate: startDate,
            endDate: endDate
        )
        
        budgetManager.addBudget(newBudget)
        dismiss()
    }
}

// MARK: - Category Picker View
struct CategoryPickerView: View {
    let categories: [TransactionCategory]
    @Binding var selectedCategory: TransactionCategory?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        isPresented = false
                    }) {
                        HStack {
                            Text(category.emoji)
                                .font(.title2)
                            Text(category.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct AddBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddBudgetView(
            budgetManager: BudgetManager(),
            transactionManager: TransactionManager()
        )
    }
}
