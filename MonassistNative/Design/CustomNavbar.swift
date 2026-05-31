import SwiftUI

/// Custom Floating Liquid Glass Navbar dengan morphing bubble
public struct CustomNavbar: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    @Binding var selectedTab: Int
    let tabs: [NavbarTab]
    let onTabChange: (Int) -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    public struct NavbarTab {
        let id: Int
        let icon: String
        let label: String
    }
    
    public init(
        selectedTab: Binding<Int>,
        tabs: [NavbarTab],
        onTabChange: @escaping (Int) -> Void
    ) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.onTabChange = onTabChange
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Floating Navbar with Premium Gradient
            HStack(spacing: 0) {
                ForEach(tabs, id: \.id) { tab in
                    ZStack {
                        // Active bubble background with glow
                        if selectedTab == tab.id {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ColorTokens.neonGreen.opacity(0.3),
                                            ColorTokens.primaryGreen.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .matchedGeometryEffect(id: "activeTab", in: namespace)
                        }
                        
                        // Item content
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text(tab.label)
                                .font(TypographyTokens.labelSmall)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(
                            selectedTab == tab.id ?
                            ColorTokens.neonGreen :
                            ColorTokens.textSecondary
                        )
                    }
                    .frame(height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab.id
                            onTabChange(tab.id)
                        }
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                }
            }
            .frame(height: 70)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                reduceTransparency ?
                ColorTokens.cardBackground :
                Color(UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 0.8))
            )
            .cornerRadius(24)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
    
    @Namespace private var namespace
}

/// Floating AI Button (Circle Glass)
public struct FloatingAIButton: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    public init(action: @escaping () -> Void) {
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
            ZStack {
                // Glow effect
                Circle()
                    .fill(ColorTokens.neonGreen.opacity(0.2))
                    .blur(radius: 8)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                
                // Glass background
                Circle()
                    .fill(
                        reduceTransparency ?
                        ColorTokens.primaryGreen :
                        Color(UIColor(red: 0.15, green: 0.45, blue: 0.35, alpha: 0.3))
                    )
                
                // Border
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ColorTokens.glassStroke.opacity(0.4),
                                ColorTokens.glassStroke.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ColorTokens.neonGreen)
            }
            .frame(width: 60, height: 60)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
    }
}

/// AI Chat Popup (Floating Glass Sheet)
public struct AIChatPopup: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    @Binding var isPresented: Bool
    @Binding var messages: [ChatMessage]
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 100, y: UIScreen.main.bounds.height - 200)
    @State private var isDragging = false
    @State private var isMinimized = false
    
    public struct ChatMessage: Identifiable {
        public let id = UUID()
        public let text: String
        public let isUser: Bool
        public let timestamp: Date
    }
    
    public init(
        isPresented: Binding<Bool>,
        messages: Binding<[ChatMessage]>
    ) {
        self._isPresented = isPresented
        self._messages = messages
    }
    
    public var body: some View {
        if isPresented {
            ZStack(alignment: .bottomTrailing) {
                // Backdrop
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }
                
                // Chat popup
                if !isMinimized {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tanya AI")
                                    .font(TypographyTokens.headlineSmall)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                Text("Analisis keuangan Anda")
                                    .font(TypographyTokens.captionSmall)
                                    .foregroundColor(ColorTokens.textSecondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isMinimized = true
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isPresented = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(ColorTokens.cardBackground)
                        .borderTop(width: 1, color: ColorTokens.glassStroke.opacity(0.2))
                        
                        // Messages
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(messages) { message in
                                        HStack(alignment: .top, spacing: 12) {
                                            if message.isUser {
                                                Spacer()
                                                
                                                Text(message.text)
                                                    .font(TypographyTokens.bodySmall)
                                                    .foregroundColor(.white)
                                                    .padding(12)
                                                    .background(ColorTokens.primaryGreen)
                                                    .cornerRadius(12)
                                            } else {
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(ColorTokens.neonGreen)
                                                    .padding(.top, 4)
                                                
                                                Text(message.text)
                                                    .font(TypographyTokens.bodySmall)
                                                    .foregroundColor(ColorTokens.textPrimary)
                                                    .padding(12)
                                                    .background(ColorTokens.cardBackground)
                                                    .cornerRadius(12)
                                                
                                                Spacer()
                                            }
                                        }
                                        .id(message.id)
                                    }
                                    
                                    if isLoading {
                                        HStack(spacing: 4) {
                                            ForEach(0..<3, id: \.self) { _ in
                                                Circle()
                                                    .fill(ColorTokens.neonGreen)
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                        .padding(12)
                                    }
                                }
                                .padding(12)
                                .onChange(of: messages.count) {
                                    withAnimation {
                                        proxy.scrollTo(messages.last?.id)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                        
                        // Input
                        HStack(spacing: 8) {
                            TextField("Tanya sesuatu...", text: $inputText)
                                .font(TypographyTokens.bodySmall)
                                .foregroundColor(ColorTokens.textPrimary)
                                .padding(10)
                                .background(ColorTokens.darkBackground)
                                .cornerRadius(8)
                            
                            Button(action: {
                                guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                
                                messages.append(ChatMessage(
                                    text: inputText,
                                    isUser: true,
                                    timestamp: Date()
                                ))
                                
                                inputText = ""
                                isLoading = true
                                
                                // Simulate AI response
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    messages.append(ChatMessage(
                                        text: "Analisis sedang diproses...",
                                        isUser: false,
                                        timestamp: Date()
                                    ))
                                    isLoading = false
                                }
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(ColorTokens.neonGreen)
                            }
                        }
                        .padding(12)
                        .background(ColorTokens.cardBackground)
                    }
                    .frame(width: 320, height: 450)
                    .background(
                        reduceTransparency ?
                        ColorTokens.cardBackground :
                        Color(UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 0.95))
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(16)
                } else {
                    // Minimized state
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isMinimized = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("Tanya AI")
                                .font(TypographyTokens.labelSmall)
                        }
                        .foregroundColor(ColorTokens.neonGreen)
                        .padding(12)
                        .background(
                            reduceTransparency ?
                            ColorTokens.primaryGreen :
                            Color(UIColor(red: 0.15, green: 0.45, blue: 0.35, alpha: 0.3))
                        )
                        .cornerRadius(12)
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - Helper Extensions
extension View {
    func borderTop(width: CGFloat, color: Color) -> some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: width)
                .background(color)
            self
        }
    }
}

// MARK: - Preview
#if DEBUG
struct CustomNavbar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                CustomNavbar(
                    selectedTab: .constant(0),
                    tabs: [
                        .init(id: 0, icon: "house.fill", label: "Home"),
                        .init(id: 1, icon: "chart.bar", label: "Analisis"),
                        .init(id: 2, icon: "clock.fill", label: "Transaksi"),
                        .init(id: 3, icon: "person.fill", label: "Profil")
                    ],
                    onTabChange: { _ in }
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(.dark)
    }
}
#endif
