import Foundation

public struct CategoryModel: Codable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public var name: String
    public var icon: String?
    public var color: String?
    public var type: String // 'income' or 'expense'
    public var budgetLimit: Double?
    public var description: String?
    public let createdAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
        case color
        case type
        case budgetLimit = "budget_limit"
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(id: Int, userId: Int, name: String, icon: String? = nil, color: String? = nil, type: String = "expense", budgetLimit: Double? = nil, description: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.budgetLimit = budgetLimit
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as Int or String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = idInt
        } else if let idStr = try? container.decode(String.self, forKey: .id), let idInt = Int(idStr) {
            self.id = idInt
        } else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: container.codingPath + [CodingKeys.id], debugDescription: "Expected Int or convertible String for id"))
        }

        // Handle userId as Int or String
        if let userInt = try? container.decode(Int.self, forKey: .userId) {
            self.userId = userInt
        } else if let userStr = try? container.decode(String.self, forKey: .userId), let userInt = Int(userStr) {
            self.userId = userInt
        } else {
            self.userId = 0 // Safe default
        }

        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Lainnya"
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "expense"
        
        // Handle budgetLimit dynamically
        if let limitDouble = try? container.decode(Double.self, forKey: .budgetLimit) {
            self.budgetLimit = limitDouble
        } else if let limitStr = try? container.decode(String.self, forKey: .budgetLimit) {
            self.budgetLimit = Double(limitStr)
        } else {
            self.budgetLimit = nil
        }

        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    public var isIncome: Bool {
        return type == "income"
    }
    
    public var isExpense: Bool {
        return type == "expense"
    }
}

public struct CategoryData: Codable, Identifiable, Hashable {
    public var id: Int
    public var name: String
    public var type: String

    public init(id: Int, name: String, type: String = "expense") {
        self.id = id
        self.name = name
        self.type = type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = idInt
        } else if let idStr = try? container.decode(String.self, forKey: .id), let idInt = Int(idStr) {
            self.id = idInt
        } else {
            self.id = 0
        }
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Lainnya"
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "expense"
    }
}
