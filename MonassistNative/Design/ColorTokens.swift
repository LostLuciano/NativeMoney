import SwiftUI

/// Global Color Design System untuk MoneyAssist
public struct ColorTokens {
    // MARK: - Primary Colors
    static let primaryGreen = Color(red: 0.15, green: 0.45, blue: 0.35)      // #267B5A
    static let neonGreen = Color(red: 0.2, green: 0.8, blue: 0.5)            // #33CC80
    
    // MARK: - Background Colors
    static let darkBackground = Color(red: 0.08, green: 0.08, blue: 0.1)     // #141416
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.15)    // #1F1F26
    
    // MARK: - Glass & Stroke
    static let glassStroke = Color(red: 0.3, green: 0.3, blue: 0.35)         // #4D4D59
    static let glassOverlay = Color.white.opacity(0.05)
    
    // MARK: - Text Colors
    static let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.97)       // #F2F2F7
    static let textSecondary = Color(red: 0.6, green: 0.6, blue: 0.65)       // #999AAA
    
    // MARK: - Status Colors
    static let dangerRed = Color(red: 0.9, green: 0.2, blue: 0.2)            // #E63333
    static let warningYellow = Color(red: 1.0, green: 0.75, blue: 0.2)       // #FFBF33
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)         // #33CC66
    
    // MARK: - Semantic Colors
    static let income = successGreen
    static let expense = dangerRed
    static let warning = warningYellow
    
    // MARK: - Adaptive Colors (Dark/Light Mode)
    static func adaptiveBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkBackground : Color.white
    }
    
    static func adaptiveCard(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? cardBackground : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    static func adaptiveText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textPrimary : Color(red: 0.1, green: 0.1, blue: 0.15)
    }
    
    static func adaptiveSecondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textSecondary : Color(red: 0.5, green: 0.5, blue: 0.55)
    }
}

// MARK: - Color Extensions
extension Color {
    static let moneyAssistPrimary = ColorTokens.primaryGreen
    static let moneyAssistNeon = ColorTokens.neonGreen
    static let moneyAssistDark = ColorTokens.darkBackground
    static let moneyAssistCard = ColorTokens.cardBackground
}
