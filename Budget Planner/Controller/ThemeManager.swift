//
//  ThemeManager.swift
//  Budget Planner
//
//  Created by mac on 26/09/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: String {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    
    init() {
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "System"
    }
    
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        case "System":
            return nil
        default:
            return nil
        }
    }
}
