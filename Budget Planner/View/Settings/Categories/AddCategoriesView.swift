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
                            .foregroundColor(.primary)
                        
                        Text("Add Categories")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Type Selector
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = .income
                    }
                }) {
                    Text("Income")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedType == .income ? Color(.systemBackground) : Color(.label))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedType == .income ? Color(.label) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = .expense
                    }
                }) {
                    Text("Expense")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedType == .expense ? Color(.systemBackground) : Color(.label))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedType == .expense ? Color(.label) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(4)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Tap to change")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                        .foregroundColor(Color(.systemBackground))
                        .background(categoryName.isEmpty ? Color.secondary : Color.primary)
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
                        .foregroundColor(.secondary)
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
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .onAppear{
            hideTabBarLegacy()
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

extension AddCategoriesView {
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

struct AddCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoriesView(isPresented: .constant(true))
            .environmentObject(CategoryStore())
    }
}
