import Foundation

public class AIService {
    public static let shared = AIService()
    private let api = APIService.shared
    
    private init() {}
    
    public func sendChatMessage(_ message: String, type: String = "general") async throws -> [String: Any] {
        let body: [String: Any] = [
            "message": message,
            "type": type
        ]
        return try await api.post(endpoint: "/chat/message", body: body)
    }
    
    public func getRecommendations() async throws -> [String: Any] {
        return try await api.get(endpoint: "/recommendations")
    }
    
    public func generateRecommendations() async throws -> [String: Any] {
        return try await api.post(endpoint: "/recommendations/generate", body: [:])
    }
    
    public func scanReceipt(fileData: Data, fileName: String) async throws -> [String: Any] {
        return try await api.postMultipart(
            endpoint: "/chat/receipt",
            fileData: fileData,
            fileName: fileName,
            fieldName: "image"
        )
    }
    
    public func generateTransaction(prompt: String) async throws -> [String: Any] {
        let body: [String: Any] = ["prompt": prompt]
        return try await api.post(endpoint: "/buatin", body: body)
    }
}
