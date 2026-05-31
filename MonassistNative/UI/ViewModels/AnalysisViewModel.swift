import Foundation
import Combine

@MainActor
public class AnalysisViewModel: ObservableObject {
    @Published var monthlySummary: MonthlySummaryModel?
    @Published var categorySummaries: [CategorySummaryModel] = []
    @Published var trendData: [TrendDataModel] = []
    @Published var aiInsights: [AIInsightModel] = []
    @Published var budgets: [BudgetModel] = []
    
    @Published var selectedPeriod: AnalysisPeriod = .month
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    public enum AnalysisPeriod {
        case week
        case month
        case year
        
        var endpoint: String {
            switch self {
            case .week:
                return "7"
            case .month:
                return "30"
            case .year:
                return "365"
            }
        }
    }
    
    private let apiService = APIService.shared
    
    public init() {}
    
    // MARK: - Public Methods
    public func loadAnalysisData() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Load monthly summary
            let summaryResponse = try await apiService.get(endpoint: "/summary/monthly")
            if let data = summaryResponse["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let summary = try JSONDecoder().decode(MonthlySummaryModel.self, from: jsonData)
                await MainActor.run {
                    self.monthlySummary = summary
                }
            }
            
            // Load category summaries
            let categoryResponse = try await apiService.get(endpoint: "/summary/category")
            if let data = categoryResponse["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let summaries = try JSONDecoder().decode([CategorySummaryModel].self, from: jsonData)
                await MainActor.run {
                    self.categorySummaries = summaries
                }
            }
            
            // Load trend data
            let trendResponse = try await apiService.get(endpoint: "/summary/trend?days=\(selectedPeriod.endpoint)")
            if let data = trendResponse["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let trends = try JSONDecoder().decode([TrendDataModel].self, from: jsonData)
                await MainActor.run {
                    self.trendData = trends
                }
            }
            
            // Load AI insights
            let insightResponse = try await apiService.get(endpoint: "/ai/insights")
            if let data = insightResponse["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let insights = try JSONDecoder().decode([AIInsightModel].self, from: jsonData)
                await MainActor.run {
                    self.aiInsights = insights
                }
            }
            
            // Load budgets
            let budgetResponse = try await apiService.get(endpoint: "/budgets")
            if let data = budgetResponse["data"] as? [[String: Any]] {
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
    
    public func getTotalIncome() -> Double {
        monthlySummary?.totalIncome ?? 0
    }
    
    public func getTotalExpense() -> Double {
        monthlySummary?.totalExpense ?? 0
    }
    
    public func getNetBalance() -> Double {
        monthlySummary?.netBalance ?? 0
    }
    
    public func getTopExpenseCategory() -> CategorySummaryModel? {
        categorySummaries.filter { $0.totalAmount > 0 }.max { $0.totalAmount < $1.totalAmount }
    }
    
    public func getBudgetProgress() -> Double {
        guard !budgets.isEmpty else { return 0 }
        let totalProgress = budgets.reduce(0) { $0 + $1.progress }
        return totalProgress / Double(budgets.count)
    }
}
