//
//  EmojiPickerView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI
import UIKit
struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var currentSelection = "" // Local state to track selection
    
    // Comprehensive emoji collection organized by categories
    private let emojiCategories: [(String, [String])] = [
        ("Money & Finance", ["💰", "💎", "💳", "💵", "💴", "💶", "💷", "🪙", "💸", "🏧", "🏪", "🏬", "💼", "📊", "📈", "📉", "💹"]),
        ("Food & Drink", ["🍔", "🍕", "🌭", "🥪", "🌮", "🌯", "🥙", "🥚", "🍳", "🥘", "🍲", "🥗", "🍿", "🧈", "🥞", "🧇", "🥓", "🍖", "🍗", "🌶️", "🥒", "🥬", "🥕", "🧄", "☕", "🍺", "🍷", "🥤", "🧃"]),
        ("Transport", ["🚗", "🚕", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "🏍️", "🛵", "🚲", "🛴", "✈️", "🛩️", "🚁", "🚂", "🚝", "🚄", "🚅", "🚈", "🚞", "🚋", "🚃", "🚖", "🛳️", "⛵"]),
        ("Home & Living", ["🏠", "🏡", "🏢", "🏣", "🏤", "🏥", "🏦", "🏨", "🏩", "🏪", "🏫", "🏬", "🏭", "🏯", "🏰", "🗼", "🗽", "⛪", "🕌", "🛕", "🕍", "⛩️", "🕋"]),
        ("Shopping & Objects", ["🛒", "🛍️", "👕", "👔", "👗", "👠", "👟", "👜", "🎒", "👓", "🕶️", "💍", "📱", "💻", "⌚", "📺", "📻", "📷", "📸", "🎮", "🕹️", "🎲", "🧩"]),
        ("Health & Medical", ["💊", "💉", "🩹", "🩺", "🦷", "🦴", "👩‍⚕️", "👨‍⚕️", "🏥", "🚑", "⚕️", "🧬", "🔬", "🧪"]),
        ("Education", ["📚", "📖", "📝", "✏️", "🖊️", "🖍️", "📐", "📏", "📌", "📍", "🎓", "🏫", "👩‍🎓", "👨‍🎓", "👩‍🏫", "👨‍🏫", "🧑‍💻"]),
        ("Entertainment", ["🎮", "🕹️", "🎬", "🎭", "🎪", "🎨", "🎯", "🎲", "🃏", "🧩", "🎸", "🎹", "🥁", "🎤", "🎧", "📺", "📻", "🎵", "🎶"]),
        ("Activities & Sports", ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳", "🪁", "🏹", "🎣", "🤿", "🏊‍♀️", "🏊‍♂️", "🚴‍♀️", "🚴‍♂️"]),
        ("Work & Business", ["💼", "👔", "💻", "📊", "📈", "📉", "💹", "🏢", "🏪", "🏬", "🏭", "🏦", "💰", "💳", "💵", "📞", "☎️", "📠", "🖨️", "📧", "📮"]),
        ("Smileys & Emotion", ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "☺️", "😚", "😙", "🥲", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔"])
    ]
    
    // Filter emojis based on search text
    private var filteredCategories: [(String, [String])] {
        if searchText.isEmpty {
            return emojiCategories
        } else {
            let allEmojis = emojiCategories.flatMap { $0.1 }
            return [("Search Results", allEmojis)]
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search emojis...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(12)
                .background(Color.secondary)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Emoji Grid
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(filteredCategories, id: \.0) { category in
                            VStack(alignment: .leading, spacing: 12) {
                                // Category Title
                                if searchText.isEmpty {
                                    Text(category.0)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal)
                                }
                                
                                // Emoji Grid
                                LazyVGrid(
                                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7),
                                    spacing: 8
                                ) {
                                    ForEach(category.1, id: \.self) { emoji in
                                        EmojiButton(
                                            emoji: emoji,
                                            isSelected: currentSelection == emoji,
                                            onTap: {
                                                selectEmoji(emoji)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !currentSelection.isEmpty {
                            selectedEmoji = currentSelection
                        }
                        dismiss()
                    }
                    .disabled(currentSelection.isEmpty)
                }
            }
        }
        .onAppear {
            currentSelection = selectedEmoji
            hideTabBarLegacy()
        }
    }
    
    // MARK: - Actions
    
    private func selectEmoji(_ emoji: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            currentSelection = emoji
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}
extension EmojiPickerView {
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
// MARK: - Emoji Button Component

struct EmojiButton: View {
    let emoji: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(
                    isSelected ?
                    Color.blue.opacity(0.3) :
                    Color(.clear)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.blue : Color.clear,
                            lineWidth: 2
                        )
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

// MARK: - Preview

struct EmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerView(selectedEmoji: .constant("😀"))
    }
}
