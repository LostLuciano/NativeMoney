import Foundation

public struct UserModel: Codable, Identifiable, Hashable {
    public let id: Int
    public var name: String
    public var email: String
    public var phone: String?
    public var avatarUrl: String?
    public var bio: String?
    public var currency: String
    public var language: String
    public var theme: String
    public var notificationsEnabled: Bool
    public var telegramId: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case avatarUrl = "avatar_url"
        case bio
        case currency
        case language
        case theme
        case notificationsEnabled = "notifications_enabled"
        case telegramId = "telegram_id"
    }

    public init(id: Int, name: String, email: String, phone: String? = nil, avatarUrl: String? = nil, bio: String? = nil, currency: String = "IDR", language: String = "id", theme: String = "dark", notificationsEnabled: Bool = true, telegramId: Int? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.currency = currency
        self.language = language
        self.theme = theme
        self.notificationsEnabled = notificationsEnabled
        self.telegramId = telegramId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as either String or Int from backend dynamically
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = idInt
        } else if let idStr = try? container.decode(String.self, forKey: .id), let idInt = Int(idStr) {
            self.id = idInt
        } else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: container.codingPath + [CodingKeys.id], debugDescription: "Expected Int or convertible String for id"))
        }

        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? "IDR"
        self.language = try container.decodeIfPresent(String.self, forKey: .language) ?? "id"
        self.theme = try container.decodeIfPresent(String.self, forKey: .theme) ?? "dark"
        
        // Handle notificationsEnabled dynamically
        if let boolVal = try? container.decode(Bool.self, forKey: .notificationsEnabled) {
            self.notificationsEnabled = boolVal
        } else if let intVal = try? container.decode(Int.self, forKey: .notificationsEnabled) {
            self.notificationsEnabled = (intVal == 1)
        } else if let strVal = try? container.decode(String.self, forKey: .notificationsEnabled) {
            self.notificationsEnabled = (strVal == "1" || strVal.lowercased() == "true")
        } else {
            self.notificationsEnabled = true
        }

        // Handle telegramId dynamically
        if let telInt = try? container.decode(Int.self, forKey: .telegramId) {
            self.telegramId = telInt
        } else if let telStr = try? container.decode(String.self, forKey: .telegramId) {
            self.telegramId = Int(telStr)
        } else {
            self.telegramId = nil
        }
    }
    
    public var isTelegramConnected: Bool {
        return telegramId != nil
    }
}
