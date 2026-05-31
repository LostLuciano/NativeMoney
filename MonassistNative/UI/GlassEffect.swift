import SwiftUI

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

struct BackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
    }
}

struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(in: Capsule())
    }
}

extension View {
    func glassEffect<S: Shape>(
        _ tint: Color = Color.white.opacity(0.05),
        in shape: S = RoundedRectangle(cornerRadius: 16)
    ) -> some View {
        modifier(GlassEffectModifier(shape: shape, tint: tint))
    }
    
    func glassEffect<S: Shape>(in shape: S) -> some View {
        modifier(GlassEffectModifier(shape: shape, tint: Color.white.opacity(0.05)))
    }
    
    func backdrop() -> some View {
        modifier(BackdropModifier())
    }
}
