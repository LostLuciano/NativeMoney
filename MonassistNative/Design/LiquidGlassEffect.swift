import SwiftUI

/// Liquid Glass Effect Component untuk iOS 26+
/// Menggunakan native .glassEffect() modifier dengan fallback untuk Reduce Transparency
public struct LiquidGlassEffect: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    let intensity: CGFloat
    let cornerRadius: CGFloat
    
    public func body(content: Content) -> some View {
        if reduceTransparency {
            // Fallback untuk Reduce Transparency: solid card color
            content
                .background(ColorTokens.cardBackground)
                .cornerRadius(cornerRadius)
        } else {
            // Liquid Glass effect (iOS 26+)
            content
                .background(.glassEffect(displayMode: .always))
                .cornerRadius(cornerRadius)
        }
    }
}

/// Liquid Glass Card dengan inner highlight dan outer glow
public struct LiquidGlassCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    let content: Content
    let cornerRadius: CGFloat
    let padding: CGFloat
    let showBorder: Bool
    let showGlow: Bool
    
    public init(
        cornerRadius: CGFloat = 24,
        padding: CGFloat = 16,
        showBorder: Bool = true,
        showGlow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.showBorder = showBorder
        self.showGlow = showGlow
    }
    
    public var body: some View {
        ZStack {
            // Outer glow (subtle)
            if showGlow && !reduceTransparency {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(ColorTokens.primaryGreen.opacity(0.1))
                    .blur(radius: 12)
                    .padding(-4)
            }
            
            // Glass background
            if reduceTransparency {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(ColorTokens.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.glassEffect(displayMode: .always))
            }
            
            // Border
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ColorTokens.glassStroke.opacity(0.3),
                                ColorTokens.glassStroke.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            
            // Inner highlight (top-left)
            if !reduceTransparency {
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius / 2)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: cornerRadius / 2)
                    Spacer()
                }
                .padding(8)
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius)
                )
            }
            
            // Content
            content
                .padding(padding)
        }
    }
}

/// Liquid Glass Button dengan spring animation
public struct LiquidGlassButton: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @State private var isPressed = false
    
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    
    public enum ButtonStyle {
        case primary
        case secondary
        case danger
    }
    
    public init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.style = style
    }
    
    var backgroundColor: Color {
        switch style {
        case .primary:
            return ColorTokens.primaryGreen
        case .secondary:
            return ColorTokens.cardBackground
        case .danger:
            return ColorTokens.dangerRed
        }
    }
    
    var foregroundColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary:
            return ColorTokens.textPrimary
        }
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(TypographyTokens.labelLarge)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isPressed)
    }
}

/// Liquid Glass Navbar Item dengan morphing bubble
public struct LiquidGlassNavbarItem: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    public init(
        icon: String,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.isActive = isActive
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .scaleEffect(isPressed ? 1.15 : 1.0)
                
                Text(label)
                    .font(TypographyTokens.labelSmall)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isActive ? ColorTokens.neonGreen : ColorTokens.textSecondary)
        }
    }
}

/// Liquid Glass Sheet (Modal)
public struct LiquidGlassSheet<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    let content: Content
    let cornerRadius: CGFloat
    
    public init(
        cornerRadius: CGFloat = 28,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(ColorTokens.textSecondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            reduceTransparency ?
            ColorTokens.cardBackground :
            Color(UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 0.95))
        )
        .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
    }
}

// MARK: - Helper Extensions
extension RoundedRectangle {
    init(cornerRadius: CGFloat, corners: UIRectCorner) {
        self.init(cornerRadius: cornerRadius)
    }
}

// MARK: - Preview
#if DEBUG
struct LiquidGlassEffect_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                LiquidGlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Liquid Glass Card")
                            .font(TypographyTokens.headlineSmall)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Text("Premium glass effect dengan inner highlight")
                            .font(TypographyTokens.bodySmall)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                LiquidGlassButton(
                    title: "Primary Button",
                    icon: "checkmark",
                    style: .primary,
                    action: {}
                )
                
                HStack(spacing: 16) {
                    LiquidGlassNavbarItem(
                        icon: "house.fill",
                        label: "Home",
                        isActive: true,
                        action: {}
                    )
                    
                    LiquidGlassNavbarItem(
                        icon: "chart.bar",
                        label: "Analytics",
                        isActive: false,
                        action: {}
                    )
                }
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}
#endif
