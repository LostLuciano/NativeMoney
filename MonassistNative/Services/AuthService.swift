import Foundation

public class AuthService {
    public static let shared = AuthService()
    private let api = APIService.shared
    
    private init() {}
    
    public func register(name: String, email: String, password: String) async throws -> [String: Any] {
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        let response = try await api.post(endpoint: "/auth/register", body: body, includeAuth: false)
        
        if let success = response["success"] as? Bool, success == true, let token = response["token"] as? String {
            api.setToken(token)
        }
        return response
    }
    
    public func login(email: String, password: String) async throws -> [String: Any] {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let response = try await api.post(endpoint: "/auth/login", body: body, includeAuth: false)
        
        if let success = response["success"] as? Bool, success == true, let token = response["token"] as? String {
            api.setToken(token)
        }
        return response
    }
    
    public func logout() async throws -> Bool {
        let response = try await api.post(endpoint: "/auth/logout", body: [:])
        let success = response["success"] as? Bool ?? false
        if success {
            api.clearToken()
        }
        return success
    }
    
    public func getCurrentUser() async throws -> UserModel {
        let response = try await api.get(endpoint: "/auth/me")
        // Serialize response back to Data and decode to UserModel
        let data = try JSONSerialization.data(withJSONObject: response)
        let decoder = JSONDecoder()
        return try decoder.decode(UserModel.self, from: data)
    }
    
    public func updateProfile(
        name: String? = nil,
        phone: String? = nil,
        currency: String? = nil,
        language: String? = nil,
        theme: String? = nil,
        bio: String? = nil,
        notificationsEnabled: Bool? = nil
    ) async throws -> [String: Any] {
        var body = [String: Any]()
        if let name = name { body["name"] = name }
        if let phone = phone { body["phone"] = phone }
        if let currency = currency { body["currency"] = currency }
        if let language = language { body["language"] = language }
        if let theme = theme { body["theme"] = theme }
        if let bio = bio { body["bio"] = bio }
        if let notificationsEnabled = notificationsEnabled {
            body["notifications_enabled"] = notificationsEnabled
        }
        
        return try await api.put(endpoint: "/auth/profile", body: body)
    }
    
    public func changePassword(current: String, new: String) async throws -> [String: Any] {
        let body: [String: Any] = [
            "current_password": current,
            "new_password": new
        ]
        return try await api.post(endpoint: "/auth/change-password", body: body)
    }
}
