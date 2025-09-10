//
//  EmojiPickerView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI

struct EmojiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedEmoji: String
    @State private var searchText = ""
    
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
    
    var filteredEmojis: [String] {
        if searchText.isEmpty {
            return emojiCategories.flatMap { $0.1 }
        } else {
            return emojiCategories.flatMap { $0.1 }.filter { emoji in
                // Simple search - you could enhance this with emoji descriptions
                true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                ScrollView(showsIndicators: false) {
                    if searchText.isEmpty {
                        // Show categorized emojis
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(emojiCategories, id: \.0) { category in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(category.0)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                                        ForEach(category.1, id: \.self) { emoji in
                                            Button(action: {
                                                selectedEmoji = emoji
                                                dismiss()
                                            }) {
                                                Text(emoji)
                                                    .font(.system(size: 28))
                                                    .frame(width: 40, height: 40)
                                                    .background(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color.clear)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    } else {
                        // Show filtered emojis
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                            ForEach(filteredEmojis, id: \.self) { emoji in
                                Button(action: {
                                    selectedEmoji = emoji
                                    dismiss()
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 40, height: 40)
                                        .background(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerView(selectedEmoji: .constant("😀"))
    }
}
