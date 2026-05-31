import Foundation

public class TransactionService {
    public static let shared = TransactionService()
    private let api = APIService.shared
    
    private init() {}
    
    public func getTransactions(
        categoryId: Int? = nil,
        type: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        search: String? = nil,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [TransactionModel] {
        var endpoint = "/transactions"
        var queryItems = [URLQueryItem]()
        
        if let categoryId = categoryId {
            queryItems.append(URLQueryItem(name: "category_id", value: String(categoryId)))
        }
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let startDate = startDate {
            queryItems.append(URLQueryItem(name: "start_date", value: formatter.string(from: startDate)))
        }
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "end_date", value: formatter.string(from: endDate)))
        }
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        
        if !queryItems.isEmpty {
            var components = URLComponents()
            components.queryItems = queryItems
            if let queryString = components.percentEncodedQuery {
                endpoint += "?\(queryString)"
            }
        }
        
        let response = try await api.get(endpoint: endpoint)
        
        // Extract array from response (e.g. data or direct list)
        // If the backend wraps the transactions under "data" key:
        let list: [[String: Any]]
        if let dataArray = response["data"] as? [[String: Any]] {
            list = dataArray
        } else if let dataObj = response["data"] as? [String: Any], let items = dataObj["items"] as? [[String: Any]] {
            list = items
        } else if let items = response["items"] as? [[String: Any]] {
            list = items
        } else {
            // Safe fallback to parsing the direct response as dictionary or list, but let's assume standard response
            list = []
        }
        
        let data = try JSONSerialization.data(withJSONObject: list)
        let decoder = JSONDecoder()
        return try decoder.decode([TransactionModel].self, from: data)
    }
    
    public func addTransaction(
        categoryId: Int,
        type: String,
        amount: Double,
        description: String,
        date: Date,
        receiptUrl: String? = nil,
        tags: [String]? = nil,
        notes: String? = nil
    ) async throws -> [String: Any] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var body: [String: Any] = [
            "category_id": categoryId,
            "type": type,
            "amount": amount,
            "description": description,
            "transaction_date": formatter.string(from: date)
        ]
        
        if let receiptUrl = receiptUrl { body["receipt_url"] = receiptUrl }
        if let tags = tags { body["tags"] = tags }
        if let notes = notes { body["notes"] = notes }
        
        return try await api.post(endpoint: "/transactions", body: body)
    }
    
    public func updateTransaction(
        transactionId: Int,
        categoryId: Int? = nil,
        type: String? = nil,
        amount: Double? = nil,
        description: String? = nil,
        date: Date? = nil,
        receiptUrl: String? = nil,
        tags: [String]? = nil,
        notes: String? = nil
    ) async throws -> [String: Any] {
        var body = [String: Any]()
        if let categoryId = categoryId { body["category_id"] = categoryId }
        if let type = type { body["type"] = type }
        if let amount = amount { body["amount"] = amount }
        if let description = description { body["description"] = description }
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            body["transaction_date"] = formatter.string(from: date)
        }
        
        if let receiptUrl = receiptUrl { body["receipt_url"] = receiptUrl }
        if let tags = tags { body["tags"] = tags }
        if let notes = notes { body["notes"] = notes }
        
        return try await api.put(endpoint: "/transactions/\(transactionId)", body: body)
    }
    
    public func deleteTransaction(_ transactionId: Int) async throws -> Bool {
        let response = try await api.delete(endpoint: "/transactions/\(transactionId)")
        return response["success"] as? Bool ?? false
    }
    
    public func getStatistics(startDate: Date? = nil, endDate: Date? = nil) async throws -> [String: Any] {
        var endpoint = "/transactions/statistics"
        var queryItems = [URLQueryItem]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let startDate = startDate {
            queryItems.append(URLQueryItem(name: "start_date", value: formatter.string(from: startDate)))
        }
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "end_date", value: formatter.string(from: endDate)))
        }
        
        if !queryItems.isEmpty {
            var components = URLComponents()
            components.queryItems = queryItems
            if let queryString = components.percentEncodedQuery {
                endpoint += "?\(queryString)"
            }
        }
        
        return try await api.get(endpoint: endpoint)
    }
    
    public func getUserSummary() async throws -> [String: Any] {
        return try await api.get(endpoint: "/users/summary")
    }
}
