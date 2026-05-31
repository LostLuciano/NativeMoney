import Foundation

public struct TransactionModel: Codable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public var categoryId: Int
    public var type: String // 'income' or 'expense'
    public var amount: Double
    public var description: String
    public var transactionDate: Date
    public var receiptUrl: String?
    public var tags: [String]?
    public var notes: String?
    public let createdAt: String?
    public let updatedAt: String?
    public var category: CategoryData?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case type
        case amount
        case description
        case transactionDate = "transaction_date"
        case date // secondary key fallback
        case receiptUrl = "receipt_url"
        case tags
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case category
    }

    public init(id: Int, userId: Int, categoryId: Int, type: String, amount: Double, description: String, transactionDate: Date, receiptUrl: String? = nil, tags: [String]? = nil, notes: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, category: CategoryData? = nil) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.type = type
        self.amount = amount
        self.description = description
        self.transactionDate = transactionDate
        self.receiptUrl = receiptUrl
        self.tags = tags
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
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
            self.userId = 0
        }

        // Handle categoryId as Int or String
        if let catInt = try? container.decode(Int.self, forKey: .categoryId) {
            self.categoryId = catInt
        } else if let catStr = try? container.decode(String.self, forKey: .categoryId), let catInt = Int(catStr) {
            self.categoryId = catInt
        } else {
            self.categoryId = 0
        }

        self.type = try container.decode(String.self, forKey: .type)
        
        // Handle amount dynamically
        if let amountDouble = try? container.decode(Double.self, forKey: .amount) {
            self.amount = amountDouble
        } else if let amountStr = try? container.decode(String.self, forKey: .amount), let amountDouble = Double(amountStr) {
            self.amount = amountDouble
        } else {
            self.amount = 0.0
        }

        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        
        // Handle transactionDate or date fallbacks
        let dateString: String
        if let directDate = try? container.decode(String.self, forKey: .transactionDate) {
            dateString = directDate
        } else if let alternateDate = try? container.decode(String.self, forKey: .date) {
            dateString = alternateDate
        } else {
            dateString = ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let parsedDate = formatter.date(from: dateString) {
            self.transactionDate = parsedDate
        } else {
            // ISO8601 parsing fallback
            let isoFormatter = ISO8601DateFormatter()
            self.transactionDate = isoFormatter.date(from: dateString) ?? Date()
        }

        self.receiptUrl = try container.decodeIfPresent(String.self, forKey: .receiptUrl)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.category = try container.decodeIfPresent(CategoryData.self, forKey: .category)
    }
    
    public var isIncome: Bool {
        return type == "income"
    }
    
    public var isExpense: Bool {
        return type == "expense"
    }
    
    public var formattedAmount: String {
        let prefix = isIncome ? "+" : "-"
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        let amountString = numberFormatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        return "\(prefix) Rp \(amountString)"
    }
}
