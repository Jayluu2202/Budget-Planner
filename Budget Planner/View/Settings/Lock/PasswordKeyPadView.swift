//
//  PasswordKeyPadView.swift
//  Budget Planner
//
//  Created by mac on 09/09/25.
//

import SwiftUI

enum PasswordMode {
    case setupPass
    case confirmPass
    case unlockApp
}

struct PasswordKeyPadView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appLockManager: AppLockManager
    @State private var password = ""
    @State private var firstPassword = ""
    @State private var mode: PasswordMode = .setupPass
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var dots: [Bool] = [false, false, false, false]
    
    init(appLockManager: AppLockManager, mode: PasswordMode = .setupPass) {
        self.appLockManager = appLockManager
        self._mode = State(initialValue: mode)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Back button (only show in setup mode)
            if mode == .setupPass || mode == .confirmPass {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
            } else {
                Spacer().frame(height: 50)
            }
            
            Spacer()
            
            // Title
            Text(getTitleText())
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Password dots
            HStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(dots[index] ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, 20)
            
            Spacer()
            
            // Number pad
            VStack(spacing: 20) {
                // First row
                HStack(spacing: 60) {
                    ForEach(1...3, id: \.self) { number in
                        NumberButton(number: "\(number)") {
                            addDigit("\(number)")
                        }
                    }
                }
                
                // Second row
                HStack(spacing: 60) {
                    ForEach(4...6, id: \.self) { number in
                        NumberButton(number: "\(number)") {
                            addDigit("\(number)")
                        }
                    }
                }
                
                // Third row
                HStack(spacing: 60) {
                    ForEach(7...9, id: \.self) { number in
                        NumberButton(number: "\(number)") {
                            addDigit("\(number)")
                        }
                    }
                }
                
                // Fourth row
                HStack(spacing: 60) {
                    Spacer().frame(width: 60)
                    NumberButton(number: "0") {
                        addDigit("0")
                    }
                    Button(action: deleteDigit) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                } else if alertMessage.contains("don't match") {
                    // Reset to setup mode for password mismatch
                    clearPassword()
                    mode = .setupPass
                    firstPassword = ""
                } else if alertMessage.contains("Incorrect password") {
                    // Just clear password for retry, don't dismiss
                    clearPassword()
                }
            }
        }
    }
    
    private func getTitleText() -> String {
        switch mode {
        case .setupPass:
            return "Set Password"
        case .confirmPass:
            return "Confirm Password"
        case .unlockApp:
            return "Enter Password"
        }
    }
    
    private func addDigit(_ digit: String) {
        guard password.count < 4 else { return }
        
        password += digit
        dots[password.count - 1] = true
        
        // Auto-proceed when 4 digits are entered
        if password.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                handlePasswordComplete()
            }
        }
    }
    
    private func deleteDigit() {
        guard !password.isEmpty else { return }
        
        dots[password.count - 1] = false
        password.removeLast()
    }
    
    private func handlePasswordComplete() {
        switch mode {
        case .setupPass:
            firstPassword = password
            clearPassword()
            mode = .confirmPass
            
        case .confirmPass:
            if password == firstPassword {
                appLockManager.setPassword(password)
                alertMessage = "Password set successfully!"
                showAlert = true
            } else {
                alertMessage = "Passwords don't match. Try again."
                showAlert = true
            }
            
        case .unlockApp:
            if appLockManager.verifyPassword(password) {
                // First unlock the app
                appLockManager.unlockApp()
                // Then dismiss the view
                dismiss()
            } else {
                alertMessage = "Incorrect password. Try again."
                showAlert = true
                // Don't clear password here, let the alert handler do it
            }
        }
    }
    
    private func clearPassword() {
        password = ""
        dots = [false, false, false, false]
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 60, height: 60)
                .background(Color.clear)
        }
    }
}

struct PasswordKeyPadView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordKeyPadView(appLockManager: AppLockManager())
    }
}
