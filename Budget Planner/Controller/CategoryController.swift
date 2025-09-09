//
//  CategoryController.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import Foundation

class CategoryStore: ObservableObject {
    @Published var categories: [Category] = []
    
    private let userDefaults = UserDefaults.standard
    private let categoriesKey = "SavedCategories"
    
    init() {
        loadCategories()
        // Add default categories if none exist
        if categories.isEmpty {
            addDefaultCategories()
        }
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(at indexSet: IndexSet) {
        categories.remove(atOffsets: indexSet)
        saveCategories()
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }
    
    func updateCategory(original: Category, updated: Category) {
        if let index = categories.firstIndex(where: { $0.id == original.id }) {
            // Create a new category with the same ID but updated properties
            let updatedCategoryWithSameId = Category(
                id: original.id,
                name: updated.name,
                emoji: updated.emoji,
                type: updated.type
            )
            categories[index] = updatedCategoryWithSameId
            saveCategories()
        }
    }
    
    func getCategories(for type: Category.CategoryType) -> [Category] {
        return categories.filter { $0.type == type }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            userDefaults.set(encoded, forKey: categoriesKey)
        }
    }
    
    private func loadCategories() {
        if let data = userDefaults.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }
    
    private func addDefaultCategories() {
        let defaultCategories = [
            Category(name: "Food", emoji: "🍔", type: .expense),
            Category(name: "Transport", emoji: "🚗", type: .expense),
            Category(name: "Shopping", emoji: "🛍️", type: .expense),
            Category(name: "Bills", emoji: "📄", type: .expense),
            Category(name: "Entertainment", emoji: "🎮", type: .expense),
            Category(name: "Health", emoji: "💊", type: .expense),
            Category(name: "Education", emoji: "📚", type: .expense),
            Category(name: "Travel", emoji: "✈️", type: .expense),
            Category(name: "Salary", emoji: "💰", type: .income),
            Category(name: "Freelance", emoji: "💻", type: .income),
            Category(name: "Investment", emoji: "📈", type: .income)
        ]
        
        categories = defaultCategories
        saveCategories()
    }
}
