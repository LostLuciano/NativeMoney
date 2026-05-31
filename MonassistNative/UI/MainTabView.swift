import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAIChat = false
    @State private var aiMessages: [AIChatPopup.ChatMessage] = []
    @State private var showBuatin = false
    @State private var isLoggedIn = false
    @State private var showLoginSheet = false
    
    public init() {
        checkLoginStatus()
    }
    
    public var body: some View {
        if !isLoggedIn {
            LoginScreen()
                .onAppear {
                    checkLoginStatus()
                }
        } else {
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
                        
                        VStack(spacing: 12) {
                            FloatingAIButton(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showAIChat = true
                                }
                            })
                            
                            FloatingBuatinButton(action: {
                                showBuatin = true
                            })
                        }
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
            .sheet(isPresented: $showBuatin) {
                BuatinScreen()
            }
        }
    }
    
    private func checkLoginStatus() {
        isLoggedIn = APIService.shared.isLoggedIn
    }
}

struct FloatingBuatinButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Buatin")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.8, blue: 0.6),
                        Color(red: 0.3, green: 0.7, blue: 0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(28)
            .shadow(color: Color(red: 0.4, green: 0.8, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}
