import Foundation

public struct PaymentMethodModel: Codable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public let name: String
    public let type: String // "cash", "card", "bank_transfer", "e_wallet"
    public let icon: String
    public let createdAt: String?
    public let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case type
        case icon
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: Int,
        userId: Int,
        name: String,
        type: String,
        icon: String,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.icon = icon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Request Models
public struct CreatePaymentMethodRequest: Codable {
    public let name: String
    public let type: String
    public let icon: String
    
    public init(name: String, type: String, icon: String) {
        self.name = name
        self.type = type
        self.icon = icon
    }
}

public struct UpdatePaymentMethodRequest: Codable {
    public let name: String?
    public let type: String?
    public let icon: String?
    
    public init(name: String? = nil, type: String? = nil, icon: String? = nil) {
        self.name = name
        self.type = type
        self.icon = icon
    }
}

// MARK: - Default Payment Methods
extension PaymentMethodModel {
    static let defaultMethods: [PaymentMethodModel] = [
        PaymentMethodModel(id: 1, userId: 0, name: "Tunai", type: "cash", icon: "banknote.fill"),
        PaymentMethodModel(id: 2, userId: 0, name: "Kartu Kredit", type: "card", icon: "creditcard.fill"),
        PaymentMethodModel(id: 3, userId: 0, name: "Transfer Bank", type: "bank_transfer", icon: "building.2.fill"),
        PaymentMethodModel(id: 4, userId: 0, name: "E-Wallet", type: "e_wallet", icon: "wallet.pass.fill"),
    ]
}
