import SwiftUI

public struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingSkeletonView()
                    .padding(16)
            } else if let error = viewModel.errorMessage {
                ErrorStateView(message: error) {
                    Task {
                        await viewModel.loadHomeData()
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(viewModel.getGreeting()), \(viewModel.user?.name ?? "User")")
                                        .font(TypographyTokens.headlineLarge)
                                        .foregroundColor(ColorTokens.textPrimary)
                                    
                                    Text("Kelola keuangan Anda dengan bijak")
                                        .font(TypographyTokens.bodySmall)
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                                
                                Spacer()
                                
                                // Avatar
                                if let avatarUrl = viewModel.user?.avatarUrl, let url = URL(string: avatarUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .cornerRadius(22)
                                    } placeholder: {
                                        Circle()
                                            .fill(ColorTokens.primaryGreen)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Text(String(viewModel.user?.name.prefix(1) ?? "U"))
                                                    .font(TypographyTokens.titleMedium)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                } else {
                                    Circle()
                                        .fill(ColorTokens.primaryGreen)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Text(String(viewModel.user?.name.prefix(1) ?? "U"))
                                                .font(TypographyTokens.titleMedium)
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        }
                        .padding(16)
                        
                        // Balance Card
                        LiquidGlassCard(cornerRadius: 24, padding: 20) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Total Saldo")
                                            .font(TypographyTokens.bodySmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(viewModel.getNetBalance()))
                                            .font(TypographyTokens.displaySmall)
                                            .foregroundColor(ColorTokens.textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "shield.fill")
                                                .font(.system(size: 12, weight: .semibold))
                                            
                                            Text(viewModel.getSecurityStatus())
                                                .font(TypographyTokens.labelSmall)
                                        }
                                        .foregroundColor(ColorTokens.successGreen)
                                    }
                                }
                                
                                Divider()
                                    .background(ColorTokens.glassStroke.opacity(0.2))
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Pemasukan")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(viewModel.getTotalIncome()))
                                            .font(TypographyTokens.titleMedium)
                                            .foregroundColor(ColorTokens.successGreen)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Pengeluaran")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(viewModel.getTotalExpense()))
                                            .font(TypographyTokens.titleMedium)
                                            .foregroundColor(ColorTokens.dangerRed)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Recent Transactions
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Transaksi Terbaru")
                                    .font(TypographyTokens.headlineSmall)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                Spacer()
                                
                                NavigationLink(destination: TransactionScreen()) {
                                    Text("Lihat Semua")
                                        .font(TypographyTokens.labelSmall)
                                        .foregroundColor(ColorTokens.neonGreen)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            if viewModel.recentTransactions.isEmpty {
                                EmptyStateView(
                                    icon: "list.bullet.rectangle",
                                    title: "Belum Ada Transaksi",
                                    message: "Mulai catat transaksi Anda untuk melihat ringkasan di sini",
                                    actionTitle: "Tambah Transaksi"
                                )
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.recentTransactions.prefix(5)) { transaction in
                                        TransactionCard(
                                            transaction: transaction,
                                            category: nil
                                        )
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
        .task {
            await viewModel.loadHomeData()
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
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeScreen()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
