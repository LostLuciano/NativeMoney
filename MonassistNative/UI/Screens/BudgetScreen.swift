import SwiftUI

public struct BudgetScreen: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showAddBudget = false
    @State private var selectedBudget: BudgetModel?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.08, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Budget")
                        .font(TypographyTokens.headlineLarge)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { showAddBudget = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(ColorTokens.neonGreen)
                    }
                }
                .padding(16)
                
                if viewModel.isLoading {
                    LoadingSkeletonView()
                        .padding(16)
                } else if let error = viewModel.errorMessage {
                    ErrorStateView(message: error) {
                        Task {
                            await viewModel.loadBudgets()
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Budget Summary
                            LiquidGlassCard(cornerRadius: 28, padding: 24, showGlow: true) {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Total Budget")
                                                .font(TypographyTokens.labelSmall)
                                                .foregroundColor(ColorTokens.textSecondary)
                                            
                                            Text(formatCurrency(viewModel.getTotalBudgetLimit()))
                                                .font(TypographyTokens.displaySmall)
                                                .foregroundColor(ColorTokens.textPrimary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Terpakai")
                                                .font(TypographyTokens.labelSmall)
                                                .foregroundColor(ColorTokens.textSecondary)
                                            
                                            Text(formatCurrency(viewModel.getTotalSpent()))
                                                .font(TypographyTokens.titleMedium)
                                                .foregroundColor(ColorTokens.dangerRed)
                                        }
                                    }
                                    
                                    // Overall Progress
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(ColorTokens.cardBackground)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        ColorTokens.neonGreen,
                                                        ColorTokens.primaryGreen
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: CGFloat(viewModel.getOverallProgress()) * (UIScreen.main.bounds.width - 80))
                                    }
                                    .frame(height: 8)
                                    
                                    HStack {
                                        Text("\(Int(viewModel.getOverallProgress() * 100))% Terpakai")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Spacer()
                                        
                                        Text("Sisa: \(formatCurrency(viewModel.getTotalRemaining()))")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.successGreen)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Budget List
                            if viewModel.budgets.isEmpty {
                                EmptyStateView(
                                    icon: "target",
                                    title: "Belum Ada Budget",
                                    message: "Buat budget untuk mengontrol pengeluaran Anda",
                                    actionTitle: "Buat Budget",
                                    action: { showAddBudget = true }
                                )
                            } else {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Kategori Budget")
                                        .font(TypographyTokens.labelMedium)
                                        .foregroundColor(ColorTokens.textSecondary)
                                        .padding(.horizontal, 16)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.budgets) { budget in
                                            BudgetDetailCard(budget: budget)
                                                .onTapGesture {
                                                    selectedBudget = budget
                                                }
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
        .sheet(isPresented: $showAddBudget) {
            AddBudgetSheet(viewModel: viewModel, isPresented: $showAddBudget)
        }
        .sheet(item: $selectedBudget) { budget in
            BudgetDetailSheet(budget: budget, viewModel: viewModel)
        }
        .task {
            await viewModel.loadBudgets()
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

// MARK: - Budget Detail Card
struct BudgetDetailCard: View {
    let budget: BudgetModel
    
    var statusColor: Color {
        switch budget.status {
        case .safe:
            return ColorTokens.successGreen
        case .warning:
            return ColorTokens.warningYellow
        case .exceeded:
            return ColorTokens.dangerRed
        }
    }
    
    var body: some View {
        LiquidGlassCard(cornerRadius: 20, padding: 16, showGlow: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.categoryName ?? "Budget")
                            .font(TypographyTokens.titleMedium)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                            
                            Text(budget.status.displayText)
                                .font(TypographyTokens.captionSmall)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(budget.limitAmount))
                            .font(TypographyTokens.titleMedium)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Text("Limit")
                            .font(TypographyTokens.captionSmall)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                
                // Progress Bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ColorTokens.cardBackground)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusColor)
                        .frame(width: CGFloat(budget.progress) * (UIScreen.main.bounds.width - 80))
                }
                .frame(height: 6)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Terpakai")
                            .font(TypographyTokens.captionSmall)
                            .foregroundColor(ColorTokens.textSecondary)
                        
                        Text(formatCurrency(budget.spent ?? 0))
                            .font(TypographyTokens.labelMedium)
                            .foregroundColor(ColorTokens.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Sisa")
                            .font(TypographyTokens.captionSmall)
                            .foregroundColor(ColorTokens.textSecondary)
                        
                        Text(formatCurrency(budget.remaining))
                            .font(TypographyTokens.labelMedium)
                            .foregroundColor(statusColor)
                    }
                }
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

// MARK: - Add Budget Sheet
struct AddBudgetSheet: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var categoryId: Int?
    @State private var limitAmount = ""
    @State private var selectedMonth = Date()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.08, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Text("Buat Budget")
                        .font(TypographyTokens.headlineSmall)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                .padding(16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kategori")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.categories) { category in
                                        Button(action: { categoryId = category.id }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: category.icon)
                                                    .font(.system(size: 16))
                                                Text(category.name)
                                                    .font(TypographyTokens.captionSmall)
                                            }
                                            .frame(width: 60)
                                            .padding(8)
                                            .background(categoryId == category.id ? category.colorValue : ColorTokens.cardBackground)
                                            .foregroundColor(categoryId == category.id ? .white : ColorTokens.textSecondary)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Limit Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Limit Budget")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            TextField("0", text: $limitAmount)
                                .font(TypographyTokens.monospaceMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(ColorTokens.cardBackground)
                                .cornerRadius(10)
                        }
                        
                        // Month Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bulan")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            DatePicker("", selection: $selectedMonth, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }
                    }
                    .padding(16)
                }
                
                LiquidGlassButton(
                    title: "Buat Budget",
                    icon: "checkmark",
                    style: .primary,
                    action: {
                        guard let categoryId = categoryId, let amount = Double(limitAmount) else { return }
                        
                        Task {
                            await viewModel.createBudget(
                                categoryId: categoryId,
                                limitAmount: amount,
                                month: selectedMonth
                            )
                            isPresented = false
                        }
                    }
                )
                .padding(16)
            }
        }
    }
}

// MARK: - Budget Detail Sheet
struct BudgetDetailSheet: View {
    let budget: BudgetModel
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.08, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ColorTokens.neonGreen)
                    }
                    
                    Spacer()
                    
                    Text(budget.categoryName ?? "Budget")
                        .font(TypographyTokens.headlineSmall)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress Card
                        LiquidGlassCard(cornerRadius: 28, padding: 24, showGlow: true) {
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Limit")
                                            .font(TypographyTokens.labelSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(budget.limitAmount))
                                            .font(TypographyTokens.displaySmall)
                                            .foregroundColor(ColorTokens.textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Terpakai")
                                            .font(TypographyTokens.labelSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(budget.spent ?? 0))
                                            .font(TypographyTokens.titleMedium)
                                            .foregroundColor(ColorTokens.dangerRed)
                                    }
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ColorTokens.cardBackground)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ColorTokens.neonGreen)
                                        .frame(width: CGFloat(budget.progress) * (UIScreen.main.bounds.width - 80))
                                }
                                .frame(height: 8)
                                
                                HStack {
                                    Text("\(Int(budget.progress * 100))%")
                                        .font(TypographyTokens.labelMedium)
                                        .foregroundColor(ColorTokens.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("Sisa: \(formatCurrency(budget.remaining))")
                                        .font(TypographyTokens.labelMedium)
                                        .foregroundColor(ColorTokens.successGreen)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Delete Button
                        LiquidGlassButton(
                            title: "Hapus Budget",
                            icon: "trash.fill",
                            style: .danger,
                            action: {
                                Task {
                                    await viewModel.deleteBudget(id: budget.id)
                                    dismiss()
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }
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
struct BudgetScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BudgetScreen()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
