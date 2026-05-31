import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var aiVM: AIViewModel
    @State private var selectedTab = 0
    @State private var showCreateModal = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(showCreateModal: $showCreateModal)
                    .tabItem {
                        Label("Ringkasan", systemImage: "chart.bar.xaxis")
                    }
                    .tag(0)
                
                TransactionHistoryView()
                    .tabItem {
                        Label("Transaksi", systemImage: "clock.fill")
                    }
                    .tag(1)
                
                AIChatView()
                    .tabItem {
                        Label("Tanya AI", systemImage: "sparkles")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Pengaturan", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tabViewStyle(.sidebarAdaptable) // Adapts automatically to sidebar on iPad, regular tab bar on iPhone!
            .tabBarMinimizeBehavior(.onScrollDown) // Automatically minimizes tab bar on scroll for large pages!
        }
    }
}
