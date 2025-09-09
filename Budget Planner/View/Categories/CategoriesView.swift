//
//  CategoriesView.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var categoryStore = CategoryStore()
    @State private var selectedSegment = 0
    
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
                        
                        Text("Categories")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                NavigationLink(destination: AddCategoriesView().environmentObject(categoryStore)) {
                    Text("Add")
                        .font(.system(size: 17, weight: .medium))
                        .frame(width: 50, height: 30)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Segment Control
            Picker("Categories", selection: $selectedSegment) {
                Text("Income").tag(0)
                Text("Expense").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Categories List
            let currentType: Category.CategoryType = selectedSegment == 0 ? .income : .expense
            let filteredCategories = categoryStore.getCategories(for: currentType)
            
            if filteredCategories.isEmpty {
                VStack {
                    Spacer()
                    Text("No \(currentType.rawValue.lowercased()) categories yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("Tap 'Add' to create your first category")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredCategories) { category in
                        NavigationLink(destination: EditCategoryView(category: category).environmentObject(categoryStore)) {
                            HStack(spacing: 12) {
                                Text(category.emoji)
                                    .font(.system(size: 24))
                                Text(category.name)
                                    .font(.system(size: 17))
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4))
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete { indexSet in
                        // Note: This deletes from the filtered array, so we need to map back to the original
                        let categoriesToDelete = indexSet.map { filteredCategories[$0] }
                        categoryStore.categories.removeAll { category in
                            categoriesToDelete.contains { $0.id == category.id }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoriesView()
        }
    }
}
