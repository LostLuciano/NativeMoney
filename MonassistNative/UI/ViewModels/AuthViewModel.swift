import Foundation
import SwiftUI

@MainActor
public class AuthViewModel: ObservableObject {
    @Published public var currentUser: UserModel?
    @Published public var isLoggedIn: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showOnboarding: Bool = false
    
    public init() {
        self.isLoggedIn = APIService.shared.isLoggedIn
        self.showOnboarding = !UserDefaults.standard.bool(forKey: "has_completed_onboarding")
        if isLoggedIn {
            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    public func checkAuthStatus() {
        self.isLoggedIn = APIService.shared.isLoggedIn
    }
    
    public func fetchCurrentUser() async {
        guard isLoggedIn else { return }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await AuthService.shared.getCurrentUser()
            self.currentUser = user
            print("AuthViewModel: Fetched user -> \(user.name)")
        } catch {
            self.errorMessage = error.localizedDescription
            if APIService.shared.getToken() == nil {
                self.isLoggedIn = false
                self.currentUser = nil
            }
        }
        isLoading = false
    }
    
    public func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthService.shared.login(email: email, password: password)
            self.isLoggedIn = true
            await fetchCurrentUser()
            isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    public func register(name: String, email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthService.shared.register(name: name, email: email, password: password)
            self.isLoggedIn = true
            await fetchCurrentUser()
            isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    public func logout() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthService.shared.logout()
        } catch {
            print("Logout error: \(error)")
        }
        APIService.shared.clearToken()
        self.isLoggedIn = false
        self.currentUser = nil
        isLoading = false
    }
    
    public func updateProfile(
        name: String? = nil,
        phone: String? = nil,
        currency: String? = nil,
        language: String? = nil,
        theme: String? = nil,
        bio: String? = nil,
        notificationsEnabled: Bool? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthService.shared.updateProfile(
                name: name,
                phone: phone,
                currency: currency,
                language: language,
                theme: theme,
                bio: bio,
                notificationsEnabled: notificationsEnabled
            )
            await fetchCurrentUser()
            isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    public func completeOnboarding() {
        self.showOnboarding = false
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
    }
}
