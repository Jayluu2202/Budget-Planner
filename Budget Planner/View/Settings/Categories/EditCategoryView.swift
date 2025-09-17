//
//  EditCategoryView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI

struct EditCategoryView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var categoryStore: CategoryStore
    @Environment(\.dismiss) private var dismiss
    
    @State var category: Category
    @State private var categoryName: String
    @State private var selectedEmoji: String
    @State private var selectedType: Category.CategoryType
    @State private var showingEmojiPicker = false
    @State private var showingDeleteAlert = false
    
    init(isPresented: Binding<Bool>, category: Category) {
        self._isPresented = isPresented
        self._category = State(initialValue: category)
        self._categoryName = State(initialValue: category.name)
        self._selectedEmoji = State(initialValue: category.emoji)
        self._selectedType = State(initialValue: category.type)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Custom segmented control
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = .income
                    }
                }) {
                    Text("Income")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedType == .income ? .white : .black)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedType == .income ? Color.black : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = .expense
                    }
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
                .buttonStyle(PlainButtonStyle())
                
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
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
//        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    
                    Text("Edit Category")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
            }

            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
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
            id: category.id, // Preserve the original ID
            name: categoryName.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: selectedEmoji,
            type: selectedType
        )
        
        categoryStore.updateCategory(original: category, updated: updatedCategory)
        category = updatedCategory
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isPresented = false
    }
    
    private func deleteCategory() {
        categoryStore.deleteCategory(category)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        isPresented = false
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditCategoryView(
                isPresented: .constant(true),
                category: Category(name: "Freelance", emoji: "💻", type: .income)
            )
            .environmentObject(CategoryStore())
        }
    }
}
