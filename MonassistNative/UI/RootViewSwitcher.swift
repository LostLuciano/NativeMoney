import SwiftUI

public struct RootViewSwitcher: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var transactionVM = TransactionViewModel()
    @StateObject var aiVM = AIViewModel()
    
    public init() {}
    
    public var body: some View {
        Group {
            if authVM.showOnboarding {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else if !authVM.isLoggedIn {
                AuthView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 1.05))
                    ))
            } else {
                MainTabView()
                    .environmentObject(transactionVM)
                    .environmentObject(aiVM)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .task {
                        await transactionVM.loadData()
                    }
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.8, blendDuration: 0), value: authVM.showOnboarding)
        .animation(.spring(response: 0.55, dampingFraction: 0.8, blendDuration: 0), value: authVM.isLoggedIn)
    }
}
