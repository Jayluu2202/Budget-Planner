//
//  AddCategoriesView.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct AddCategoriesView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var categoryStore: CategoryStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: Category.CategoryType = .income
    @State private var categoryName = ""
    @State private var selectedEmoji = "😀"
    @State private var showingEmojiPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    isPresented = false
//                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text("Add Categories")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Type Selector
            Picker("Category Type", selection: $selectedType) {
                Text("Income").tag(Category.CategoryType.income)
                Text("Expense").tag(Category.CategoryType.expense)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Emoji Selector
            VStack(spacing: 16) {
                Button(action: {
                    showingEmojiPicker = true
                }) {
                    VStack(spacing: 8) {
                        Text(selectedEmoji)
                            .font(.system(size: 40))
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Tap to change")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Category Name Input
                TextField("New Category Name", text: $categoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Add Category Button
                Button(action: addCategory) {
                    Text("Add Category")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(categoryName.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(12)
                }
                .disabled(categoryName.isEmpty)
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
            }
            
            // All Categories Section
            Text("All Categories:")
                .font(.headline)
                .padding(.horizontal)
            
            // Display existing categories
            ScrollView(showsIndicators: false) {
                let filteredCategories = categoryStore.categories.filter { $0.type == selectedType }
                
                if filteredCategories.isEmpty {
                    Text("No \(selectedType.rawValue.lowercased()) categories yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                        ForEach(filteredCategories) { category in
                            VStack(spacing: 8) {
                                Text(category.emoji)
                                    .font(.system(size: 24))
                                Text(category.name)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $selectedEmoji)
        }
    }
    
    private func addCategory() {
        guard !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newCategory = Category(
            name: categoryName.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: selectedEmoji,
            type: selectedType
        )
        
        categoryStore.addCategory(newCategory)
        
        // Reset form
        categoryName = ""
        selectedEmoji = "😀"
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isPresented = false
    }
}

struct AddCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoriesView(isPresented: .constant(true))
            .environmentObject(CategoryStore())
    }
}
