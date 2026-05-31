import SwiftUI

@main
struct MonassistNativeApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authVM)
                .preferredColorScheme(.dark)
        }
    }
}
