import SwiftUI

/// Typography Design System menggunakan SF Pro
public struct TypographyTokens {
    // MARK: - Display Styles
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 24, weight: .bold, design: .default)
    
    // MARK: - Headline Styles
    static let headlineLarge = Font.system(size: 22, weight: .bold, design: .default)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .default)
    
    // MARK: - Title Styles
    static let titleLarge = Font.system(size: 16, weight: .semibold, design: .default)
    static let titleMedium = Font.system(size: 14, weight: .semibold, design: .default)
    static let titleSmall = Font.system(size: 12, weight: .semibold, design: .default)
    
    // MARK: - Body Styles
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    // MARK: - Caption Styles
    static let captionLarge = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    
    // MARK: - Monospace (untuk nominal/angka)
    static let monospaceLarge = Font.system(size: 18, weight: .semibold, design: .monospaced)
    static let monospaceMedium = Font.system(size: 16, weight: .semibold, design: .monospaced)
    static let monospaceSmall = Font.system(size: 14, weight: .regular, design: .monospaced)
}

// MARK: - Text Style Extensions
extension Text {
    func displayLarge() -> Text {
        self.font(TypographyTokens.displayLarge)
    }
    
    func headlineLarge() -> Text {
        self.font(TypographyTokens.headlineLarge)
    }
    
    func bodyMedium() -> Text {
        self.font(TypographyTokens.bodyMedium)
    }
    
    func monospaceMedium() -> Text {
        self.font(TypographyTokens.monospaceMedium)
    }
}
