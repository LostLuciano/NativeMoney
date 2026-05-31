import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case serializationError
    case unauthorized(String)
    case unprocessableEntity(String)
    case forbidden(String)
    case notFound(String)
    case serverError(String)
    case requestTimeout
    case networkError(Error)
    case unknownResponse(Int, String)
    case invalidResponseFormat
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL tidak valid."
        case .serializationError:
            return "Kesalahan format data."
        case .unauthorized(let msg):
            return msg
        case .unprocessableEntity(let msg):
            return msg
        case .forbidden(let msg):
            return msg
        case .notFound(let msg):
            return msg
        case .serverError(let msg):
            return msg
        case .requestTimeout:
            return "Koneksi habis (timeout), silakan coba lagi."
        case .networkError(let err):
            return "Kesalahan jaringan: \(err.localizedDescription)"
        case .unknownResponse(let code, let msg):
            return "Error \(code): \(msg)"
        case .invalidResponseFormat:
            return "Format respon dari server tidak valid."
        }
    }
}

public class APIService {
    public static let shared = APIService()
    
    private let baseUrl = "https://monassist.vercel.app/api"
    private var token: String?
    private var isInitialized = false
    
    private init() {
        loadToken()
    }
    
    private func loadToken() {
        if isInitialized { return }
        self.token = UserDefaults.standard.string(forKey: "auth_token")
        self.isInitialized = true
        print("APIService: Token loaded -> \(token != nil ? "Present" : "Nil")")
    }
    
    public func setToken(_ newToken: String) {
        self.token = newToken
        UserDefaults.standard.set(newToken, forKey: "auth_token")
        self.isInitialized = true
        print("APIService: Token set & stored successfully")
    }
    
    public func clearToken() {
        self.token = nil
        UserDefaults.standard.removeObject(forKey: "auth_token")
        print("APIService: Token cleared")
    }
    
    public func getToken() -> String? {
        return token
    }
    
    public var isLoggedIn: Bool {
        return token != nil
    }
    
    private func getHeaders(includeAuth: Bool = true) -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        if includeAuth, let activeToken = token {
            headers["Authorization"] = "Bearer \(activeToken)"
        }
        return headers
    }
    
    public func get(endpoint: String) async throws -> [String: Any] {
        loadToken()
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30.0
        
        getHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("GET Request -> \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    public func post(endpoint: String, body: [String: Any], includeAuth: Bool = true) async throws -> [String: Any] {
        loadToken()
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30.0
        
        getHeaders(includeAuth: includeAuth).forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw APIError.serializationError
        }
        
        print("POST Request -> \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    public func put(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        loadToken()
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 30.0
        
        getHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw APIError.serializationError
        }
        
        print("PUT Request -> \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    public func delete(endpoint: String) async throws -> [String: Any] {
        loadToken()
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 30.0
        
        getHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("DELETE Request -> \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    public func postMultipart(endpoint: String, fileData: Data, fileName: String, fieldName: String) async throws -> [String: Any] {
        loadToken()
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 45.0
        
        var headers = getHeaders()
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("POST Multipart Request -> \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> [String: Any] {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponseFormat
        }
        
        let statusCode = httpResponse.statusCode
        print("Response Code -> \(statusCode)")
        
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        let message = jsonObject?["message"] as? String ?? "Terjadi kesalahan sistem (\(statusCode))"
        
        switch statusCode {
        case 200, 201:
            if let jsonDict = jsonObject {
                return jsonDict
            } else {
                throw APIError.invalidResponseFormat
            }
        case 401:
            clearToken()
            throw APIError.unauthorized(message)
        case 422:
            throw APIError.unprocessableEntity(message)
        case 403:
            throw APIError.forbidden(message)
        case 404:
            throw APIError.notFound(message)
        case 500:
            throw APIError.serverError(message)
        default:
            throw APIError.unknownResponse(statusCode, message)
        }
    }
}
