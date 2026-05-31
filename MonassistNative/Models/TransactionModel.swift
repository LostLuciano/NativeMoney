import Foundation

public struct TransactionModel: Codable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public let type: String // "income" atau "expense"
    public let title: String
    public let merchant: String?
    public let amount: Double
    public let categoryId: Int
    public let paymentMethodId: Int?
    public let note: String?
    public let transactionDate: String // ISO 8601 format
    public let receiptImageUrl: String?
    public let locationName: String?
    public let latitude: Double?
    public let longitude: Double?
    public let isFavorite: Bool
    public let isPinned: Bool
    public let createdAt: String
    public let updatedAt: String
    
    // Relasi (optional, dari API)
    public let category: CategoryModel?
    public let paymentMethod: PaymentMethodModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case merchant
        case amount
        case categoryId = "category_id"
        case paymentMethodId = "payment_method_id"
        case note
        case transactionDate = "transaction_date"
        case receiptImageUrl = "receipt_image_url"
        case locationName = "location_name"
        case latitude
        case longitude
        case isFavorite = "is_favorite"
        case isPinned = "is_pinned"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case category
        case paymentMethod = "payment_method"
    }
    
    public init(
        id: Int,
        userId: Int,
        type: String,
        title: String,
        merchant: String? = nil,
        amount: Double,
        categoryId: Int,
        paymentMethodId: Int? = nil,
        note: String? = nil,
        transactionDate: String,
        receiptImageUrl: String? = nil,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isFavorite: Bool = false,
        isPinned: Bool = false,
        createdAt: String,
        updatedAt: String,
        category: CategoryModel? = nil,
        paymentMethod: PaymentMethodModel? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.merchant = merchant
        self.amount = amount
        self.categoryId = categoryId
        self.paymentMethodId = paymentMethodId
        self.note = note
        self.transactionDate = transactionDate
        self.receiptImageUrl = receiptImageUrl
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.paymentMethod = paymentMethod
    }
    
    // MARK: - Computed Properties
    public var isIncome: Bool {
        type.lowercased() == "income"
    }
    
    public var isExpense: Bool {
        type.lowercased() == "expense"
    }
    
    public var displayAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp \(Int(amount))"
    }
    
    public var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = formatter.date(from: transactionDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return transactionDate
    }
    
    public var displayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = formatter.date(from: transactionDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return ""
    }
    
    public var displayDateOnly: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = formatter.date(from: transactionDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return transactionDate
    }
}

// MARK: - Request Models
public struct CreateTransactionRequest: Codable {
    public let type: String
    public let title: String
    public let merchant: String?
    public let amount: Double
    public let categoryId: Int
    public let paymentMethodId: Int?
    public let note: String?
    public let transactionDate: String
    public let locationName: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case merchant
        case amount
        case categoryId = "category_id"
        case paymentMethodId = "payment_method_id"
        case note
        case transactionDate = "transaction_date"
        case locationName = "location_name"
    }
    
    public init(
        type: String,
        title: String,
        merchant: String? = nil,
        amount: Double,
        categoryId: Int,
        paymentMethodId: Int? = nil,
        note: String? = nil,
        transactionDate: String,
        locationName: String? = nil
    ) {
        self.type = type
        self.title = title
        self.merchant = merchant
        self.amount = amount
        self.categoryId = categoryId
        self.paymentMethodId = paymentMethodId
        self.note = note
        self.transactionDate = transactionDate
        self.locationName = locationName
    }
}

public struct UpdateTransactionRequest: Codable {
    public let type: String?
    public let title: String?
    public let merchant: String?
    public let amount: Double?
    public let categoryId: Int?
    public let paymentMethodId: Int?
    public let note: String?
    public let transactionDate: String?
    public let locationName: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case merchant
        case amount
        case categoryId = "category_id"
        case paymentMethodId = "payment_method_id"
        case note
        case transactionDate = "transaction_date"
        case locationName = "location_name"
    }
}
