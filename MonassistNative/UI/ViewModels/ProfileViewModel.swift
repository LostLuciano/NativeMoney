import Foundation
import Combine

@MainActor
public class ProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    public init() {}
    
    // MARK: - Public Methods
    public func loadProfile() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await apiService.get(endpoint: "/me")
            if let userData = response["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: userData)
                let user = try JSONDecoder().decode(UserModel.self, from: jsonData)
                await MainActor.run {
                    self.user = user
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    public func logout() async {
        do {
            _ = try await apiService.post(endpoint: "/logout", body: [:])
            apiService.clearToken()
            
            // Trigger app to return to login screen
            // This should be handled by RootViewSwitcher observing auth state
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
