//
//  appLock.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct appLock: View {
    @Environment(\.dismiss) var dismiss
    @State private var lockSwitchIsOn = false
    @State private var faceSwitchIsOn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 🔙 Custom Back Button
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("App Lock")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Secure your app with authentication methods")
                    .font(.system(size: 14.5))
                    .foregroundColor(.secondary)
                
                // 🔐 Password Lock Row
                HStack(spacing: 15) {
                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Password Lock")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(lockSwitchIsOn ? "Enabled" : "Not enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $lockSwitchIsOn)
                        .labelsHidden()
                }
                .frame(height: 50)
                
                // 😎 FaceID Row
                HStack(spacing: 15) {
                    Image("face-id")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FaceID")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(faceSwitchIsOn ? "Enabled" : "Not enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $faceSwitchIsOn)
                        .labelsHidden()
                }
                .frame(height: 50)
                
            }
            .navigationBarHidden(true)
            .padding() // ✅ Add padding inside the box
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16) // 🔲 Rounded rectangle
                    .fill(Color(.systemGray6))     // light background color
            )
            .overlay( // Optional border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal) // ✅ space from screen edges
            Spacer()
        }
        
    }
}

struct appLock_Previews: PreviewProvider {
    static var previews: some View {
        appLock()
    }
}
