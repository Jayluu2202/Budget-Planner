//
//  AddBudgetView.swift
//  Budget Planner
//
//  Updated to use CategoryStore instead of TransactionManager
//

import SwiftUI

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var budgetManager: BudgetManager
    @StateObject private var categoryStore = CategoryStore() // Use CategoryStore instead
    
    @State private var selectedCategory: Category? // Changed from TransactionCategory to Category
    @State private var budgetAmount: String = ""
    @State private var sliderValue: Double = 1000
    @State private var description: String = ""
    @State private var showCategoryPicker = false
    
    private var expenseCategories: [Category] { // Changed return type
        return categoryStore.getCategories(for: .expense) // Use categoryStore method
    }
    
    private var isFormValid: Bool {
        return selectedCategory != nil && !budgetAmount.isEmpty && (Double(budgetAmount) ?? 0) > 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Create Budget")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Invisible button for balance
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            // Main Content Card
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    // Category Selection
                    buildCategorySection()
                    
                    // Budget Amount Section with Slider
                    buildBudgetAmountSection()
                    
                    // Description Section
                    buildDescriptionSection()
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .background(Color.white)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            
            Spacer()
            
            // Create Budget Button
            createBudgetButton
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
                .background(Color.white)
        }
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
        .onChange(of: sliderValue) { newValue in
            budgetAmount = String(Int(newValue))
        }
        .onChange(of: budgetAmount) { newValue in
            if let doubleValue = Double(newValue), doubleValue >= 0 && doubleValue <= 10000 {
                sliderValue = doubleValue
            }
        }
        .onAppear {
            // Initialize the text field with slider value
            budgetAmount = String(Int(sliderValue))
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildCategorySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Category")
                .font(.headline)
                .foregroundColor(.secondary)
            
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
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Amount")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Single Slider - Removed the duplicate rectangles
            VStack(spacing: 12) {
                // Range labels
                HStack {
                    Text("₹0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₹10,000")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Actual Slider
                Slider(value: $sliderValue, in: 0...10000, step: 100)
                    .accentColor(.black)
            }
            .padding(.horizontal, 4)
            
            // Amount Input Field
            HStack {
                Text("₹")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                TextField("1000", text: $budgetAmount)
                    .font(.title2)
                    .keyboardType(.numberPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: budgetAmount) { newValue in
                        // Validate input range
                        if let doubleValue = Double(newValue) {
                            if doubleValue > 10000 {
                                budgetAmount = "10000"
                                sliderValue = 10000
                            } else if doubleValue < 0 {
                                budgetAmount = "0"
                                sliderValue = 0
                            }
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private func buildDescriptionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 100)
                
                TextEditor(text: $description)
                    .padding(10)
                    .frame(height: 100)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if description.isEmpty {
                    Text("Add description...")
                        .foregroundColor(.secondary)
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
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
    }
    
    // MARK: - Actions
    
    private func createBudget() {
        guard let category = selectedCategory else { return }
        guard let amount = Double(budgetAmount), amount > 0 else { return }
        
        // Convert Category to TransactionCategory for Budget
        let transactionCategory = TransactionCategory(
            name: category.name,
            emoji: category.emoji,
            type: category.type == .expense ? .expense : .income
        )
        
        let newBudget = Budget(
            category: transactionCategory,
            budgetAmount: amount,
            description: description.isEmpty ? "Budget for \(category.name)" : description,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        )
        
        budgetManager.addBudget(newBudget) // Removed transaction sync for now
        dismiss()
    }
}

// MARK: - Category Picker View (Updated for Category model)
struct CategoryPickerView: View {
    let categories: [Category] // Changed from TransactionCategory to Category
    @Binding var selectedCategory: Category? // Changed from TransactionCategory to Category
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

// MARK: - Custom Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct AddBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddBudgetView(
            budgetManager: BudgetManager()
        )
    }
}
