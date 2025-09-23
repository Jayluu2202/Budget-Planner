//
//  themeSettings.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct themeSettings: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTheme : String
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
                            .font(.title2)
                            .fontWeight(.semibold)
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
                themeOption(title: "Light", systemImage: "light", selectedTheme: $selectedTheme)
                themeOption(title: "Dark", systemImage: "dark", selectedTheme: $selectedTheme)
                themeOption(title: "System", systemImage: "system", selectedTheme: $selectedTheme)
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
            print("Checking theme Selected: \(selectedTheme)")
        }) {
            HStack {
                Image(systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.body)
                Spacer()
                
                
                
//                if selectedTheme == title {
//                    print("Checking theme Selected: \(selectedTheme)")
//                }
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

//struct themeSettings_Previews: PreviewProvider {
//    @State var selectedState : String = "Light"
//    static var previews: some View {
//
//        themeSettings(selectedTheme: $selectedState)
//    }
//}
