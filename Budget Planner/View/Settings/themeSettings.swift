//
//  themeSettings.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct themeSettings: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTheme : String = "Light"
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 20){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text("Theme Settings")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                
                Text("Choose your preferred theme mode")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
            
            // Options
            VStack(spacing: 12) {
                themeOption(title: "Light", systemImage: "sun.max", selectedTheme: $selectedTheme)
                themeOption(title: "Dark", systemImage: "moon", selectedTheme: $selectedTheme)
                themeOption(title: "System", systemImage: "circle.lefthalf.fill", selectedTheme: $selectedTheme)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Reusable Option Row
struct themeOption: View {
    let title: String
    let systemImage: String
    @Binding var selectedTheme: String
    
    var body: some View {
        Button(action: {
            selectedTheme = title
        }) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.body)
                Spacer()
                
                if selectedTheme == title {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedTheme == title ? Color.black : Color.gray.opacity(0.3), lineWidth: selectedTheme == title ? 1.5 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct themeSettings_Previews: PreviewProvider {
    static var previews: some View {
        themeSettings()
    }
}
