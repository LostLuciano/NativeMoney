import Foundation
import Combine

@MainActor
public class BudgetViewModel: ObservableObject {
    @Published var budgets: [BudgetModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    public init() {}
    
    // MARK: - Public Methods
    public func loadBudgets() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await apiService.get(endpoint: "/budgets")
            if let data = response["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let budgets = try JSONDecoder().decode([BudgetModel].self, from: jsonData)
                await MainActor.run {
                    self.budgets = budgets
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
    
    public func createBudget(categoryId: Int, limitAmount: Double, month: Date) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthString = formatter.string(from: month)
        
        let body: [String: Any] = [
            "category_id": categoryId,
            "limit_amount": limitAmount,
            "month": monthString
        ]
        
        do {
            let response = try await apiService.post(endpoint: "/budgets", body: body)
            
            if let data = response["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let budget = try JSONDecoder().decode(BudgetModel.self, from: jsonData)
                
                await MainActor.run {
                    self.budgets.append(budget)
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func deleteBudget(id: Int) async {
        do {
            _ = try await apiService.delete(endpoint: "/budgets/\(id)")
            
            await MainActor.run {
                self.budgets.removeAll { $0.id == id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Calculation Methods
    public func getTotalBudgetLimit() -> Double {
        budgets.reduce(0) { $0 + $1.limitAmount }
    }
    
    public func getTotalSpent() -> Double {
        budgets.reduce(0) { $0 + ($1.spent ?? 0) }
    }
    
    public func getTotalRemaining() -> Double {
        budgets.reduce(0) { $0 + $1.remaining }
    }
    
    public func getOverallProgress() -> Double {
        let total = getTotalBudgetLimit()
        guard total > 0 else { return 0 }
        return getTotalSpent() / total
    }
}
