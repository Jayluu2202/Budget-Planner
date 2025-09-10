//
//  AppLockManager.swift
//  Budget Planner
//
//  Created by mac on 10/09/25.
//

import SwiftUI
import LocalAuthentication
import CryptoKit

class AppLockManager: ObservableObject {
    @Published var isLocked = false
    @Published var isPasswordEnabled = false
    @Published var isFaceIDEnabled = false
    
    private let passwordKey = "app_password"
    private let passwordEnabledKey = "password_enabled"
    private let faceIDEnabledKey = "faceid_enabled"
    
    init() {
        loadSettings()
        // Lock app on initialization if any security is enabled
        if isPasswordEnabled || isFaceIDEnabled {
            isLocked = true
        }
    }
    
    // MARK: - Password Management
    func setPassword(_ password: String) {
        let hashedPassword = hashPassword(password)
        UserDefaults.standard.set(hashedPassword, forKey: passwordKey)
        UserDefaults.standard.set(true, forKey: passwordEnabledKey)
        isPasswordEnabled = true
    }
    
    func verifyPassword(_ password: String) -> Bool {
        guard let storedHash = UserDefaults.standard.string(forKey: passwordKey) else {
            return false
        }
        let hashedInput = hashPassword(password)
        return hashedInput == storedHash
    }
    
    func removePassword() {
        UserDefaults.standard.removeObject(forKey: passwordKey)
        UserDefaults.standard.set(false, forKey: passwordEnabledKey)
        isPasswordEnabled = false
        
        // Also disable FaceID when password is removed
        setFaceIDEnabled(false)
    }
    
    // MARK: - Face ID Management
    func setFaceIDEnabled(_ enabled: Bool) {
        // FaceID can only be enabled if password is also enabled
        if enabled && !isPasswordEnabled {
            return
        }
        
        UserDefaults.standard.set(enabled, forKey: faceIDEnabledKey)
        isFaceIDEnabled = enabled
    }
    
    // MARK: - App Lock Management
    func lockApp() {
        if isPasswordEnabled || isFaceIDEnabled {
            isLocked = true
        }
    }
    
    func unlockApp() {
        isLocked = false
    }
    
    // MARK: - Private Methods
    private func loadSettings() {
        isPasswordEnabled = UserDefaults.standard.bool(forKey: passwordEnabledKey)
        isFaceIDEnabled = UserDefaults.standard.bool(forKey: faceIDEnabledKey)
        
        // Ensure FaceID is disabled if password is not enabled
        if isFaceIDEnabled && !isPasswordEnabled {
            setFaceIDEnabled(false)
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Biometric Authentication
    func checkBiometricAvailability() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}
