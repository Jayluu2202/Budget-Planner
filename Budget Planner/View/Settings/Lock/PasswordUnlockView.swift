//
//  PasswordUnlockView.swift
//  Budget Planner
//
//  Created by mac on 10/09/25.
//

import SwiftUI
import LocalAuthentication

struct PasswordUnlockView: View {
    @ObservedObject var appLockManager: AppLockManager
    @State private var showPasswordKeypad = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 80))
                .foregroundColor(.black)
            
            VStack(spacing: 16) {
                Text("App Locked")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your password or use biometric authentication to unlock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 20) {
                if appLockManager.isPasswordEnabled {
                    Button(action: {
                        showPasswordKeypad = true
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Enter Password")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                
                if appLockManager.isFaceIDEnabled {
                    Button(action: {
                        authenticateWithBiometrics()
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Use Face ID")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showPasswordKeypad) {
            // Pass the unlock mode to the PasswordKeyPadView
            PasswordKeyPadView(appLockManager: appLockManager, mode: .unlockApp)
        }
        .onAppear {
            if appLockManager.isFaceIDEnabled {
                authenticateWithBiometrics()
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Budget Planner") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        appLockManager.unlockApp()
                    }
                }
            }
        }
    }
}

struct PasswordUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordUnlockView(appLockManager: AppLockManager())
    }
}
