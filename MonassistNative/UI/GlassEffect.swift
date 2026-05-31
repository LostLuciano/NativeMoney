import SwiftUI

/// A custom modifier that applies a frosted glass (glassmorphism) effect to SwiftUI views.
/// This creates a semi-transparent, blurred background effect commonly seen in modern iOS apps.
struct GlassEffectModifier<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color
    
    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(tint)
                    .backdrop()
            }
    }
}

/// Backdrop blur effect using Material (iOS 15+)
struct BackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
    }
}

extension View {
    /// Applies a glass effect (frosted glass/glassmorphism) to the view.
    /// - Parameters:
    ///   - tint: The tint color for the glass effect (default: white with 5% opacity)
    ///   - shape: The shape to apply the effect to (default: RoundedRectangle with 16pt radius)
    /// - Returns: A view with the glass effect applied
    func glassEffect<S: Shape>(
        _ tint: Color = Color.white.opacity(0.05),
        in shape: S = RoundedRectangle(cornerRadius: 16)
    ) -> some View {
        modifier(GlassEffectModifier(shape: shape, tint: tint))
    }
    
    /// Applies a glass effect with a specific shape.
    /// - Parameter shape: The shape to apply the effect to
    /// - Returns: A view with the glass effect applied
    func glassEffect<S: Shape>(in shape: S) -> some View {
        modifier(GlassEffectModifier(shape: shape, tint: Color.white.opacity(0.05)))
    }
    
    /// Applies a backdrop blur effect.
    /// - Returns: A view with the backdrop blur applied
    func backdrop() -> some View {
        modifier(BackdropModifier())
    }
}
