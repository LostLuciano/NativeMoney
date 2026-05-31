import Foundation

public struct BudgetModel: Codable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public let categoryId: Int
    public let limitAmount: Double
    public let month: Int
    public let year: Int
    public let createdAt: String?
    public let updatedAt: String?
    
    // Relasi (optional)
    public let category: CategoryModel?
    public let spent: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case limitAmount = "limit_amount"
        case month
        case year
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case category
        case spent
    }
    
    public init(
        id: Int,
        userId: Int,
        categoryId: Int,
        limitAmount: Double,
        month: Int,
        year: Int,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        category: CategoryModel? = nil,
        spent: Double? = nil
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.limitAmount = limitAmount
        self.month = month
        self.year = year
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.spent = spent
    }
    
    // MARK: - Computed Properties
    public var categoryName: String? {
        category?.name
    }
    
    public var progress: Double {
        guard limitAmount > 0 else { return 0 }
        let spent = self.spent ?? 0
        return min(spent / limitAmount, 1.0)
    }
    
    public var remaining: Double {
        max(limitAmount - (spent ?? 0), 0)
    }
    
    public var isExceeded: Bool {
        (spent ?? 0) > limitAmount
    }
    
    public var isWarning: Bool {
        progress >= 0.8 && !isExceeded
    }
    
    public var status: BudgetStatus {
        if isExceeded {
            return .exceeded
        } else if isWarning {
            return .warning
        } else {
            return .safe
        }
    }
    
    public enum BudgetStatus {
        case safe
        case warning
        case exceeded
        
        public var displayText: String {
            switch self {
            case .safe:
                return "Aman"
            case .warning:
                return "Mendekati Limit"
            case .exceeded:
                return "Melebihi Limit"
            }
        }
    }
}

// MARK: - Request Models
public struct CreateBudgetRequest: Codable {
    public let categoryId: Int
    public let limitAmount: Double
    public let month: Int
    public let year: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case limitAmount = "limit_amount"
        case month
        case year
    }
    
    public init(categoryId: Int, limitAmount: Double, month: Int, year: Int) {
        self.categoryId = categoryId
        self.limitAmount = limitAmount
        self.month = month
        self.year = year
    }
}

public struct UpdateBudgetRequest: Codable {
    public let limitAmount: Double?
    
    enum CodingKeys: String, CodingKey {
        case limitAmount = "limit_amount"
    }
    
    public init(limitAmount: Double? = nil) {
        self.limitAmount = limitAmount
    }
}
