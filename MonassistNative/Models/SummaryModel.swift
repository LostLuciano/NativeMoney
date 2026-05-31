import Foundation

public struct MonthlySummaryModel: Codable, Identifiable {
    public let id: String
    public let month: Int
    public let year: Int
    public let totalIncome: Double
    public let totalExpense: Double
    public let netBalance: Double
    
    enum CodingKeys: String, CodingKey {
        case month
        case year
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
        case netBalance = "net_balance"
    }
    
    public init(
        month: Int,
        year: Int,
        totalIncome: Double,
        totalExpense: Double,
        netBalance: Double
    ) {
        self.id = "\(year)-\(month)"
        self.month = month
        self.year = year
        self.totalIncome = totalIncome
        self.totalExpense = totalExpense
        self.netBalance = netBalance
    }
    
    public var displayMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var components = DateComponents()
        components.month = month
        components.year = year
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(month)/\(year)"
    }
}

public struct CategorySummaryModel: Codable, Identifiable {
    public let id: Int
    public let categoryId: Int
    public let categoryName: String
    public let categoryIcon: String
    public let categoryColor: String
    public let totalAmount: Double
    public let percentage: Double
    public let transactionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case categoryName = "category_name"
        case categoryIcon = "category_icon"
        case categoryColor = "category_color"
        case totalAmount = "total_amount"
        case percentage
        case transactionCount = "transaction_count"
    }
    
    public init(
        id: Int,
        categoryId: Int,
        categoryName: String,
        categoryIcon: String,
        categoryColor: String,
        totalAmount: Double,
        percentage: Double,
        transactionCount: Int
    ) {
        self.id = id
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
        self.categoryColor = categoryColor
        self.totalAmount = totalAmount
        self.percentage = percentage
        self.transactionCount = transactionCount
    }
}

public struct TrendDataModel: Codable, Identifiable {
    public let id: String
    public let date: String
    public let income: Double
    public let expense: Double
    public let balance: Double
    
    public init(date: String, income: Double, expense: Double, balance: Double) {
        self.id = date
        self.date = date
        self.income = income
        self.expense = expense
        self.balance = balance
    }
    
    public var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: date) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM"
            return displayFormatter.string(from: date)
        }
        return date
    }
}

public struct AIInsightModel: Codable, Identifiable {
    public let id: Int
    public let userId: Int
    public let type: String // "spending_alert", "saving_tip", "category_insight", "trend_analysis"
    public let title: String
    public let message: String
    public let period: String
    public let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case message
        case period
        case createdAt = "created_at"
    }
    
    public init(
        id: Int,
        userId: Int,
        type: String,
        title: String,
        message: String,
        period: String,
        createdAt: String
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.period = period
        self.createdAt = createdAt
    }
    
    public var icon: String {
        switch type {
        case "spending_alert":
            return "exclamationmark.circle.fill"
        case "saving_tip":
            return "lightbulb.fill"
        case "category_insight":
            return "chart.pie.fill"
        case "trend_analysis":
            return "chart.line.uptrend.xyaxis"
        default:
            return "sparkles"
        }
    }
}
