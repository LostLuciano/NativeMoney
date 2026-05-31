import SwiftUI

// MARK: - Transaction Card
public struct TransactionCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    let transaction: TransactionModel
    let category: CategoryModel?
    let onTap: () -> Void
    
    public init(
        transaction: TransactionModel,
        category: CategoryModel? = nil,
        onTap: @escaping () -> Void = {}
    ) {
        self.transaction = transaction
        self.category = category
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(category?.colorValue.opacity(0.2) ?? ColorTokens.primaryGreen.opacity(0.2))
                    
                    Image(systemName: category?.icon ?? "questionmark.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(category?.colorValue ?? ColorTokens.primaryGreen)
                }
                .frame(width: 44, height: 44)
                
                // Transaction Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.title)
                        .font(TypographyTokens.titleMedium)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    HStack(spacing: 8) {
                        if let merchant = transaction.merchant {
                            Text(merchant)
                                .font(TypographyTokens.captionSmall)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                        
                        Text(transaction.displayTime)
                            .font(TypographyTokens.captionSmall)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                
                Spacer()
                
                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text(transaction.displayAmount)
                        .font(TypographyTokens.titleMedium)
                        .foregroundColor(transaction.isIncome ? ColorTokens.successGreen : ColorTokens.dangerRed)
                    
                    if let paymentMethod = transaction.paymentMethod {
                        Text(paymentMethod.name)
                            .font(TypographyTokens.captionSmall)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(ColorTokens.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Budget Card
public struct BudgetCard: View {
    let budget: BudgetModel
    let category: CategoryModel?
    
    public init(budget: BudgetModel, category: CategoryModel? = nil) {
        self.budget = budget
        self.category = category
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(category?.colorValue.opacity(0.2) ?? ColorTokens.primaryGreen.opacity(0.2))
                        
                        Image(systemName: category?.icon ?? "questionmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(category?.colorValue ?? ColorTokens.primaryGreen)
                    }
                    .frame(width: 36, height: 36)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category?.name ?? "Budget")
                            .font(TypographyTokens.titleMedium)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Text(budget.status.displayText)
                            .font(TypographyTokens.captionSmall)
                            .foregroundColor(statusColor)
                    }
                }
                
                Spacer()
                
                Text(budget.displayLimitAmount)
                    .font(TypographyTokens.titleMedium)
                    .foregroundColor(ColorTokens.textPrimary)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorTokens.cardBackground)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(statusColor)
                    .frame(width: CGFloat(budget.progress) * (UIScreen.main.bounds.width - 64))
            }
            .frame(height: 6)
            
            HStack {
                Text("Terpakai: \(budget.displaySpent)")
                    .font(TypographyTokens.captionSmall)
                    .foregroundColor(ColorTokens.textSecondary)
                
                Spacer()
                
                Text("Sisa: \(budget.displayRemaining)")
                    .font(TypographyTokens.captionSmall)
                    .foregroundColor(ColorTokens.textSecondary)
            }
        }
        .padding(12)
        .background(ColorTokens.cardBackground)
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch budget.status {
        case .safe:
            return ColorTokens.successGreen
        case .warning:
            return ColorTokens.warningYellow
        case .exceeded:
            return ColorTokens.dangerRed
        }
    }
}

// MARK: - Insight Card
public struct InsightCard: View {
    let insight: AIInsightModel
    
    public init(insight: AIInsightModel) {
        self.insight = insight
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: insight.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorTokens.neonGreen)
                
                Text(insight.title)
                    .font(TypographyTokens.titleMedium)
                    .foregroundColor(ColorTokens.textPrimary)
                
                Spacer()
            }
            
            Text(insight.message)
                .font(TypographyTokens.bodySmall)
                .foregroundColor(ColorTokens.textSecondary)
                .lineLimit(3)
        }
        .padding(12)
        .background(ColorTokens.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Empty State View
public struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(ColorTokens.textSecondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(TypographyTokens.headlineSmall)
                    .foregroundColor(ColorTokens.textPrimary)
                
                Text(message)
                    .font(TypographyTokens.bodySmall)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                LiquidGlassButton(
                    title: actionTitle,
                    icon: "plus.circle.fill",
                    style: .primary,
                    action: action
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

// MARK: - Loading Skeleton
public struct LoadingSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorTokens.cardBackground)
                        .frame(width: 44, height: 44)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorTokens.cardBackground)
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorTokens.cardBackground)
                            .frame(height: 10)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(ColorTokens.darkBackground)
                .cornerRadius(12)
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

// MARK: - Error State View
public struct ErrorStateView: View {
    let message: String
    let action: (() -> Void)?
    
    public init(message: String, action: (() -> Void)? = nil) {
        self.message = message
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(ColorTokens.dangerRed)
            
            VStack(spacing: 8) {
                Text("Terjadi Kesalahan")
                    .font(TypographyTokens.headlineSmall)
                    .foregroundColor(ColorTokens.textPrimary)
                
                Text(message)
                    .font(TypographyTokens.bodySmall)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let action = action {
                LiquidGlassButton(
                    title: "Coba Lagi",
                    icon: "arrow.clockwise",
                    style: .primary,
                    action: action
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

// MARK: - Shimmering Modifier
struct ShimmeringModifier: ViewModifier {
    @State private var isShimmering = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isShimmering ? 300 : -300)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isShimmering)
            )
            .onAppear {
                isShimmering = true
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}

// MARK: - Budget Helper Extensions
extension BudgetModel {
    var displayLimitAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: limitAmount)) ?? "Rp \(Int(limitAmount))"
    }
    
    var displaySpent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: spent ?? 0)) ?? "Rp \(Int(spent ?? 0))"
    }
    
    var displayRemaining: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: remaining)) ?? "Rp \(Int(remaining))"
    }
}
