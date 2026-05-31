import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAIChat = false
    @State private var aiMessages: [AIChatPopup.ChatMessage] = []
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        HomeScreen()
                    }
                case 1:
                    NavigationStack {
                        AnalysisScreen()
                    }
                case 2:
                    NavigationStack {
                        TransactionScreen()
                    }
                case 3:
                    NavigationStack {
                        ProfileScreen()
                    }
                default:
                    NavigationStack {
                        HomeScreen()
                    }
                }
            }
            
            // Floating AI Button + Chat Popup
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    FloatingAIButton(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAIChat = true
                        }
                    })
                    .padding(.trailing, 16)
                    .padding(.bottom, 90)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // AI Chat Popup
            AIChatPopup(isPresented: $showAIChat, messages: $aiMessages)
        }
        .overlay(alignment: .bottom) {
            // Custom Navbar
            CustomNavbar(
                selectedTab: $selectedTab,
                tabs: [
                    .init(id: 0, icon: "house.fill", label: "Home"),
                    .init(id: 1, icon: "chart.bar", label: "Analisis"),
                    .init(id: 2, icon: "clock.fill", label: "Transaksi"),
                    .init(id: 3, icon: "person.fill", label: "Profil")
                ],
                onTabChange: { _ in }
            )
        }
    }
}
