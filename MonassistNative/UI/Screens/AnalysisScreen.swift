import SwiftUI

public struct AnalysisScreen: View {
    @StateObject private var viewModel = AnalysisViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Analisis")
                        .font(TypographyTokens.headlineLarge)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    // Period Selector
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        Text("7 Hari").tag(AnalysisViewModel.AnalysisPeriod.week)\n                        Text("30 Hari").tag(AnalysisViewModel.AnalysisPeriod.month)
                        Text("1 Tahun").tag(AnalysisViewModel.AnalysisPeriod.year)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedPeriod) { _ in
                        Task {
                            await viewModel.loadAnalysisData()
                        }
                    }
                }
                .padding(16)
                
                if viewModel.isLoading {
                    LoadingSkeletonView()
                        .padding(16)
                } else if let error = viewModel.errorMessage {
                    ErrorStateView(message: error) {
                        Task {
                            await viewModel.loadAnalysisData()
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Summary Cards
                            HStack(spacing: 12) {
                                SummaryCard(
                                    title: "Pemasukan",
                                    amount: viewModel.getTotalIncome(),
                                    icon: "arrow.down.circle.fill",
                                    color: ColorTokens.successGreen
                                )
                                
                                SummaryCard(
                                    title: "Pengeluaran",
                                    amount: viewModel.getTotalExpense(),
                                    icon: "arrow.up.circle.fill",
                                    color: ColorTokens.dangerRed
                                )
                                
                                SummaryCard(
                                    title: "Saldo",
                                    amount: viewModel.getNetBalance(),
                                    icon: "wallet.pass.fill",
                                    color: ColorTokens.neonGreen
                                )
                            }
                            .padding(.horizontal, 16)
                            
                            // Category Chart
                            if !viewModel.categorySummaries.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Pengeluaran per Kategori")
                                        .font(TypographyTokens.headlineSmall)
                                        .foregroundColor(ColorTokens.textPrimary)
                                        .padding(.horizontal, 16)
                                    
                                    LiquidGlassCard(cornerRadius: 16, padding: 16) {
                                        VStack(spacing: 16) {
                                            // Donut Chart (Placeholder)
                                            ZStack {
                                                Circle()
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                ColorTokens.primaryGreen,
                                                                ColorTokens.neonGreen
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 20
                                                    )
                                                
                                                VStack(spacing: 4) {
                                                    Text(formatCurrency(viewModel.getTotalExpense()))
                                                        .font(TypographyTokens.titleMedium)
                                                        .foregroundColor(ColorTokens.textPrimary)
                                                    
                                                    Text("Total Pengeluaran")
                                                        .font(TypographyTokens.captionSmall)
                                                        .foregroundColor(ColorTokens.textSecondary)
                                                }
                                            }
                                            .frame(height: 200)
                                            
                                            // Category List
                                            VStack(spacing: 8) {
                                                ForEach(viewModel.categorySummaries.prefix(5)) { category in
                                                    HStack(spacing: 12) {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            HStack(spacing: 8) {
                                                                Image(systemName: category.categoryIcon)
                                                                    .font(.system(size: 14, weight: .semibold))
                                                                    .foregroundColor(Color(hex: category.categoryColor))
                                                                
                                                                Text(category.categoryName)
                                                                    .font(TypographyTokens.labelMedium)
                                                                    .foregroundColor(ColorTokens.textPrimary)
                                                            }
                                                            
                                                            Text("\(Int(category.percentage))% • \(category.transactionCount) transaksi")
                                                                .font(TypographyTokens.captionSmall)
                                                                .foregroundColor(ColorTokens.textSecondary)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        Text(formatCurrency(category.totalAmount))
                                                            .font(TypographyTokens.labelMedium)
                                                            .foregroundColor(ColorTokens.textPrimary)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            // Trend Chart
                            if !viewModel.trendData.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Tren Pengeluaran")
                                        .font(TypographyTokens.headlineSmall)
                                        .foregroundColor(ColorTokens.textPrimary)
                                        .padding(.horizontal, 16)
                                    
                                    LiquidGlassCard(cornerRadius: 16, padding: 16) {
                                        VStack(spacing: 12) {
                                            // Line Chart (Placeholder)\n                                            HStack(alignment: .bottom, spacing: 4) {
                                                ForEach(viewModel.trendData.suffix(7)) { data in
                                                    VStack(spacing: 4) {
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .fill(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [
                                                                        ColorTokens.neonGreen,
                                                                        ColorTokens.primaryGreen
                                                                    ]),
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                            .frame(height: CGFloat(data.expense / 100000))
                                                        
                                                        Text(data.displayDate)
                                                            .font(TypographyTokens.captionSmall)
                                                            .foregroundColor(ColorTokens.textSecondary)
                                                    }
                                                }
                                            }
                                            .frame(height: 150)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            // AI Insights
                            if !viewModel.aiInsights.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Insight AI")
                                        .font(TypographyTokens.headlineSmall)
                                        .foregroundColor(ColorTokens.textPrimary)
                                        .padding(.horizontal, 16)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.aiInsights.prefix(3)) { insight in
                                            InsightCard(insight: insight)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            // Budget Overview
                            if !viewModel.budgets.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Budget")
                                        .font(TypographyTokens.headlineSmall)
                                        .foregroundColor(ColorTokens.textPrimary)
                                        .padding(.horizontal, 16)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.budgets.prefix(5)) { budget in
                                            BudgetCard(budget: budget)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .task {
            await viewModel.loadAnalysisData()
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp \(Int(amount))"
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        LiquidGlassCard(cornerRadius: 16, padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(TypographyTokens.labelSmall)
                        .foregroundColor(ColorTokens.textSecondary)
                }
                
                Text(formatCurrency(amount))
                    .font(TypographyTokens.titleMedium)
                    .foregroundColor(ColorTokens.textPrimary)
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp \(Int(amount))"
    }
}

#if DEBUG
struct AnalysisScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AnalysisScreen()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
