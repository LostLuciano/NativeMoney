import Foundation
import Combine

@MainActor
public class HomeViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var recentTransactions: [TransactionModel] = []
    @Published var monthlySummary: MonthlySummaryModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    public init() {}
    
    // MARK: - Public Methods
    public func loadHomeData() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Load user profile
            let userResponse = try await apiService.get(endpoint: "/me")
            if let userData = userResponse["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: userData)
                let user = try JSONDecoder().decode(UserModel.self, from: jsonData)
                await MainActor.run {
                    self.user = user
                }
            }
            
            // Load recent transactions
            let transResponse = try await apiService.get(endpoint: "/transactions?limit=5")
            if let transData = transResponse["data"] as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: transData)
                let transactions = try JSONDecoder().decode([TransactionModel].self, from: jsonData)
                await MainActor.run {
                    self.recentTransactions = transactions
                }
            }
            
            // Load monthly summary
            let summaryResponse = try await apiService.get(endpoint: "/summary/monthly")
            if let summaryData = summaryResponse["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: summaryData)
                let summary = try JSONDecoder().decode(MonthlySummaryModel.self, from: jsonData)
                await MainActor.run {
                    self.monthlySummary = summary
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
    
    public func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<11:
            return "Pagi"
        case 11..<15:
            return "Siang"
        case 15..<18:
            return "Sore"
        default:
            return "Malam"
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
    
    public func getSecurityStatus() -> String {
        // Placeholder: bisa diintegrasikan dengan logic keamanan
        return "Safe"
    }
}
