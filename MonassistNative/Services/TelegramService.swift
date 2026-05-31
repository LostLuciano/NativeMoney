import Foundation

public class TelegramService {
    public static let shared = TelegramService()
    private let api = APIService.shared
    
    private init() {}
    
    public func generatePairingCode() async throws -> [String: Any] {
        return try await api.post(endpoint: "/auth/telegram-code", body: [:])
    }
    
    public func disconnectTelegram() async throws -> [String: Any] {
        return try await api.post(endpoint: "/auth/telegram-disconnect", body: [:])
    }
}
