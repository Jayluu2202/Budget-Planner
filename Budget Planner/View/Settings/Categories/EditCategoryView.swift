//
//  EditCategoryView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI

struct EditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryStore: CategoryStore
    
    @State var category: Category
    @State private var categoryName: String
    @State private var selectedEmoji: String
    @State private var selectedType: Category.CategoryType
    @State private var showingEmojiPicker = false
    @State private var showingDeleteAlert = false
    
    init(category: Category) {
        self._category = State(initialValue: category)
        self._categoryName = State(initialValue: category.name)
        self._selectedEmoji = State(initialValue: category.emoji)
        self._selectedType = State(initialValue: category.type)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text("Edit Categories")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                
                // Delete button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Replace your Picker with this custom segmented control
            HStack(spacing: 0) {
                Button(action: {
                    selectedType = .income
                }) {
                    Text("Income")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedType == .income ? .white : .black)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedType == .income ? Color.black : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button(action: {
                    selectedType = .expense
                }) {
                    Text("Expense")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedType == .expense ? .white : .black)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedType == .expense ? Color.black : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(4)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            
            // Type Selector
//            Picker("Category Type", selection: $selectedType) {
//                Text("Income").tag(Category.CategoryType.income)
//                Text("Expense").tag(Category.CategoryType.expense)
//            }
//
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal)
//            .onAppear {
//                // Customize the segmented control appearance
//                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.black
//                UISegmentedControl.appearance().backgroundColor = UIColor.clear
//                UISegmentedControl.appearance().setTitleTextAttributes([
//                    .foregroundColor: UIColor.white
//                ], for: .selected)
//                UISegmentedControl.appearance().setTitleTextAttributes([
//                    .foregroundColor: UIColor.black
//                ], for: .normal)
//            }
            // Emoji Selector
            VStack(spacing: 16) {
                Button(action: {
                    showingEmojiPicker.toggle()
                }) {
                    Text(selectedEmoji)
                        .font(.system(size: 40))
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Category Name Input
                TextField("Category Name", text: $categoryName)
                    .padding()
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray6), lineWidth: 3)
                    )
                    .padding(.horizontal)
                
                // Save Button
                Button(action: saveCategory) {
                    Text("Save")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(categoryName.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(12)
                }
                .disabled(categoryName.isEmpty)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $selectedEmoji)
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteCategory()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this category? This action cannot be undone.")
        }
    }
    
    private func saveCategory() {
        guard !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let updatedCategory = Category(
            name: categoryName.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: selectedEmoji,
            type: selectedType
        )
        
        categoryStore.updateCategory(original: category, updated: updatedCategory)
        category = updatedCategory
        dismiss()
    }
    
    private func deleteCategory() {
        categoryStore.deleteCategory(category)
        dismiss()
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditCategoryView(category: Category(name: "Freelance", emoji: "💻", type: .income))
            .environmentObject(CategoryStore())
    }
}
