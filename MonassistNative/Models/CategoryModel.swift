import Foundation
import SwiftUI

public struct CategoryModel: Codable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public let name: String
    public let icon: String
    public let color: String // Hex color
    public let type: String // "income" atau "expense"
    public let createdAt: String?
    public let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
        case color
        case type
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: Int,
        userId: Int,
        name: String,
        icon: String,
        color: String,
        type: String,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    public var colorValue: Color {
        Color(hex: color) ?? ColorTokens.primaryGreen
    }
    
    public var isIncome: Bool {
        type.lowercased() == "income"
    }
    
    public var isExpense: Bool {
        type.lowercased() == "expense"
    }
}

// MARK: - Request Models
public struct CreateCategoryRequest: Codable {
    public let name: String
    public let icon: String
    public let color: String
    public let type: String
    
    public init(name: String, icon: String, color: String, type: String) {
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
    }
}

public struct UpdateCategoryRequest: Codable {
    public let name: String?
    public let icon: String?
    public let color: String?
    public let type: String?
    
    public init(name: String? = nil, icon: String? = nil, color: String? = nil, type: String? = nil) {
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        guard hex.count == 6 else { return nil }
        
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        
        guard scanner.scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

// MARK: - Default Categories
extension CategoryModel {
    static let defaultExpenseCategories: [CategoryModel] = [
        CategoryModel(id: 1, userId: 0, name: "Makanan", icon: "fork.knife", color: "#FF6B6B", type: "expense"),
        CategoryModel(id: 2, userId: 0, name: "Transportasi", icon: "car.fill", color: "#4ECDC4", type: "expense"),
        CategoryModel(id: 3, userId: 0, name: "Hiburan", icon: "film.fill", color: "#FFE66D", type: "expense"),
        CategoryModel(id: 4, userId: 0, name: "Belanja", icon: "bag.fill", color: "#95E1D3", type: "expense"),
        CategoryModel(id: 5, userId: 0, name: "Kesehatan", icon: "heart.fill", color: "#F38181", type: "expense"),
        CategoryModel(id: 6, userId: 0, name: "Utilitas", icon: "bolt.fill", color: "#AA96DA", type: "expense"),
    ]
    
    static let defaultIncomeCategories: [CategoryModel] = [
        CategoryModel(id: 7, userId: 0, name: "Gaji", icon: "banknote.fill", color: "#52B788", type: "income"),
        CategoryModel(id: 8, userId: 0, name: "Bonus", icon: "gift.fill", color: "#FFD60A", type: "income"),
        CategoryModel(id: 9, userId: 0, name: "Investasi", icon: "chart.line.uptrend.xyaxis", color: "#06D6A0", type: "income"),
        CategoryModel(id: 10, userId: 0, name: "Lainnya", icon: "ellipsis.circle.fill", color: "#A8DADC", type: "income"),
    ]
}
