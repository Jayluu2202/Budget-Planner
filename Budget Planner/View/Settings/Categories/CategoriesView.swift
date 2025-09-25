import SwiftUI
import UIKit
struct CategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var categoryStore = CategoryStore()
    @State private var selectedSegment = 0
    @State private var selectedCategory: Category?
    @State private var showEditView = false
    @State private var showAddView = false
    
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
                
                Button(action: {
                    // Remove the withAnimation wrapper here
                    showAddView = true
                }) {
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
            
            // Categories ScrollView
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
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredCategories) { category in
                            Button(action: {
                                selectedCategory = category
                                showEditView = true
                            }) {
                                HStack(spacing: 12) {
                                    Text(category.emoji)
                                        .font(.system(size: 24))
                                    Text(category.name)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(.clear)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.4))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    categoryStore.categories.removeAll { $0.id == category.id }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear{
            hideTabBarLegacy()
        }
        .onDisappear{
            showTabBarLegacy()
        }
        .overlay(
            Group {
                if showAddView {
                    NavigationView {
                        AddCategoriesView(isPresented: $showAddView)
                            .environmentObject(categoryStore)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(1)
                }
            }
        )
        .animation(.easeInOut(duration: 0.6), value: showAddView)
        
        // Edit view can keep the default bottom-to-top animation
        .overlay(
            Group {
                if showEditView, let selectedCategory = selectedCategory {
                    NavigationView {
                        EditCategoryView(isPresented: $showEditView, category: selectedCategory)
                            .environmentObject(categoryStore)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(1)
                }
            }
        )
        .animation(.easeInOut(duration: 0.6), value: showEditView)
    }
}

extension CategoriesView {
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
struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoriesView()
        }
    }
}
