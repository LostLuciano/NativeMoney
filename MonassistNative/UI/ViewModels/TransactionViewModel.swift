import Foundation
import Combine

@MainActor
public class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionModel] = []
    @Published var filteredTransactions: [TransactionModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var paymentMethods: [PaymentMethodModel] = []
    @Published var monthlySummary: MonthlySummaryModel?
    
    @Published var searchText = ""
    @Published var selectedCategory: Int?
    @Published var selectedPaymentMethod: Int?
    @Published var selectedType: String? // "income" atau "expense"
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var minAmount: Double?
    @Published var maxAmount: Double?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    public init() {}
    
    // MARK: - Public Methods
    public func loadTransactions() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await apiService.get(endpoint: "/transactions")
            if let data = response["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let transactions = try JSONDecoder().decode([TransactionModel].self, from: jsonData)
                await MainActor.run {
                    self.transactions = transactions
                    self.applyFilters()
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    public func loadCategories() async {
        do {
            let response = try await apiService.get(endpoint: "/categories")
            if let data = response["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let categories = try JSONDecoder().decode([CategoryModel].self, from: jsonData)
                await MainActor.run {
                    self.categories = categories
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func loadPaymentMethods() async {
        do {
            let response = try await apiService.get(endpoint: "/payment-methods")
            if let data = response["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let methods = try JSONDecoder().decode([PaymentMethodModel].self, from: jsonData)
                await MainActor.run {
                    self.paymentMethods = methods
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func loadMonthlySummary() async {
        do {
            let response = try await apiService.get(endpoint: "/summary/monthly")
            if let data = response["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let summary = try JSONDecoder().decode(MonthlySummaryModel.self, from: jsonData)
                await MainActor.run {
                    self.monthlySummary = summary
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func createTransaction(
        type: String,
        title: String,
        merchant: String?,
        amount: Double,
        categoryId: Int,
        paymentMethodId: Int?,
        note: String?,
        transactionDate: String,
        locationName: String?
    ) async {
        let request = CreateTransactionRequest(
            type: type,
            title: title,
            merchant: merchant,
            amount: amount,
            categoryId: categoryId,
            paymentMethodId: paymentMethodId,
            note: note,
            transactionDate: transactionDate,
            locationName: locationName
        )
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            let body = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            let response = try await apiService.post(endpoint: "/transactions", body: body)
            
            if let data = response["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let transaction = try JSONDecoder().decode(TransactionModel.self, from: jsonData)
                
                await MainActor.run {
                    self.transactions.insert(transaction, at: 0)
                    self.applyFilters()
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func deleteTransaction(id: Int) async {
        do {
            _ = try await apiService.delete(endpoint: "/transactions/\(id)")
            
            await MainActor.run {
                self.transactions.removeAll { $0.id == id }
                self.applyFilters()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func toggleFavorite(id: Int) async {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else { return }
        
        let isFavorite = transactions[index].isFavorite
        
        do {
            let body: [String: Any] = ["is_favorite": !isFavorite]
            _ = try await apiService.put(endpoint: "/transactions/\(id)", body: body)
            
            await MainActor.run {
                self.transactions[index] = TransactionModel(
                    id: self.transactions[index].id,
                    userId: self.transactions[index].userId,
                    type: self.transactions[index].type,
                    title: self.transactions[index].title,
                    merchant: self.transactions[index].merchant,
                    amount: self.transactions[index].amount,
                    categoryId: self.transactions[index].categoryId,
                    paymentMethodId: self.transactions[index].paymentMethodId,
                    note: self.transactions[index].note,
                    transactionDate: self.transactions[index].transactionDate,
                    receiptImageUrl: self.transactions[index].receiptImageUrl,
                    locationName: self.transactions[index].locationName,
                    latitude: self.transactions[index].latitude,
                    longitude: self.transactions[index].longitude,
                    isFavorite: !isFavorite,
                    isPinned: self.transactions[index].isPinned,
                    createdAt: self.transactions[index].createdAt,
                    updatedAt: self.transactions[index].updatedAt,
                    category: self.transactions[index].category,
                    paymentMethod: self.transactions[index].paymentMethod
                )
                self.applyFilters()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Filter Methods
    public func applyFilters() {
        var filtered = transactions
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                (transaction.merchant?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Category filter
        if let categoryId = selectedCategory {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }
        
        // Payment method filter
        if let paymentMethodId = selectedPaymentMethod {
            filtered = filtered.filter { $0.paymentMethodId == paymentMethodId }
        }
        
        // Type filter
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }
        
        // Date range filter
        if let startDate = startDate, let endDate = endDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            filtered = filtered.filter { transaction in
                if let transDate = formatter.date(from: String(transaction.transactionDate.prefix(10))) {
                    return transDate >= startDate && transDate <= endDate
                }
                return false
            }
        }
        
        // Amount range filter
        if let minAmount = minAmount {
            filtered = filtered.filter { $0.amount >= minAmount }
        }
        
        if let maxAmount = maxAmount {
            filtered = filtered.filter { $0.amount <= maxAmount }
        }
        
        self.filteredTransactions = filtered.sorted { $0.transactionDate > $1.transactionDate }
    }
    
    public func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedPaymentMethod = nil
        selectedType = nil
        startDate = nil
        endDate = nil
        minAmount = nil
        maxAmount = nil
        applyFilters()
    }
    
    // MARK: - Grouping Methods
    public func groupTransactionsByDate() -> [String: [TransactionModel]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var grouped: [String: [TransactionModel]] = [:]
        
        for transaction in filteredTransactions {
            let dateKey = String(transaction.transactionDate.prefix(10))
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(transaction)
        }
        
        return grouped
    }
}
