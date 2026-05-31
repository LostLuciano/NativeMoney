import Foundation

public class CategoryService {
    public static let shared = CategoryService()
    private let api = APIService.shared
    
    private init() {}
    
    public func getCategories() async throws -> [CategoryModel] {
        let response = try await api.get(endpoint: "/categories")
        
        let list: [[String: Any]]
        if let dataArray = response["data"] as? [[String: Any]] {
            list = dataArray
        } else if let items = response["items"] as? [[String: Any]] {
            list = items
        } else if let dataObj = response["data"] as? [String: Any], let items = dataObj["items"] as? [[String: Any]] {
            list = items
        } else {
            // Assume direct response if list structure is different
            list = []
        }
        
        let data = try JSONSerialization.data(withJSONObject: list)
        let decoder = JSONDecoder()
        return try decoder.decode([CategoryModel].self, from: data)
    }
    
    public func addCategory(
        name: String,
        type: String,
        icon: String? = nil,
        color: String? = nil,
        budgetLimit: Double? = nil,
        description: String? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = [
            "name": name,
            "type": type
        ]
        
        if let icon = icon { body["icon"] = icon }
        if let color = color { body["color"] = color }
        if let budgetLimit = budgetLimit { body["budget_limit"] = budgetLimit }
        if let description = description { body["description"] = description }
        
        return try await api.post(endpoint: "/categories", body: body)
    }
    
    public func updateCategory(
        categoryId: Int,
        name: String? = nil,
        icon: String? = nil,
        color: String? = nil,
        type: String? = nil,
        budgetLimit: Double? = nil,
        description: String? = nil
    ) async throws -> [String: Any] {
        var body = [String: Any]()
        if let name = name { body["name"] = name }
        if let icon = icon { body["icon"] = icon }
        if let color = color { body["color"] = color }
        if let type = type { body["type"] = type }
        if let budgetLimit = budgetLimit { body["budget_limit"] = budgetLimit }
        if let description = description { body["description"] = description }
        
        return try await api.put(endpoint: "/categories/\(categoryId)", body: body)
    }
    
    public func deleteCategory(_ categoryId: Int) async throws -> Bool {
        let response = try await api.delete(endpoint: "/categories/\(categoryId)")
        return response["success"] as? Bool ?? false
    }
}
