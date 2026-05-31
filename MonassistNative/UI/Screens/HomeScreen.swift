import SwiftUI

public struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddTransaction = false
    @State private var showAIChat = false
    @State private var chatMessages: [AIChatPopup.ChatMessage] = []
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.08, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                    VStack(spacing: 24) {
                        // Premium Header with Avatar
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(viewModel.getGreeting()), \(viewModel.user?.name ?? "User")")
                                        .font(TypographyTokens.headlineLarge)
                                        .foregroundColor(ColorTokens.textPrimary)
                                    
                                    Text("Kelola keuangan Anda dengan bijak")
                                        .font(TypographyTokens.bodySmall)
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                                
                                Spacer()
                                
                                // Premium Avatar with Glow
                                ZStack {
                                    Circle()
                                        .fill(ColorTokens.neonGreen.opacity(0.2))
                                        .blur(radius: 12)
                                    
                                    if let avatarUrl = viewModel.user?.avatarUrl, let url = URL(string: avatarUrl) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 48, height: 48)
                                                .cornerRadius(24)
                                        } placeholder: {
                                            Circle()
                                                .fill(ColorTokens.primaryGreen)
                                                .frame(width: 48, height: 48)
                                                .overlay(
                                                    Text(String(viewModel.user?.name.prefix(1) ?? "U"))
                                                        .font(TypographyTokens.titleMedium)
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    } else {
                                        Circle()
                                            .fill(ColorTokens.primaryGreen)
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Text(String(viewModel.user?.name.prefix(1) ?? "U"))
                                                    .font(TypographyTokens.titleMedium)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .frame(width: 56, height: 56)
                            }
                        }
                        .padding(16)
                        
                        // Premium Balance Card with Enhanced Glass Effect
                        LiquidGlassCard(cornerRadius: 28, padding: 24, showGlow: true) {
                            VStack(alignment: .leading, spacing: 20) {
                                // Main Balance
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "wallet.pass.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(ColorTokens.neonGreen)
                                        
                                        Text("Total Saldo")
                                            .font(TypographyTokens.labelSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                    }
                                    
                                    Text(formatCurrency(viewModel.getNetBalance()))
                                        .font(TypographyTokens.displaySmall)
                                        .foregroundColor(ColorTokens.textPrimary)
                                }
                                
                                Divider()
                                    .background(ColorTokens.glassStroke.opacity(0.2))
                                
                                // Income & Expense Row
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(ColorTokens.successGreen)
                                            
                                            Text("Pemasukan")
                                                .font(TypographyTokens.captionSmall)
                                                .foregroundColor(ColorTokens.textSecondary)
                                        }
                                        
                                        Text(formatCurrency(viewModel.getTotalIncome()))
                                            .font(TypographyTokens.titleMedium)
                                            .foregroundColor(ColorTokens.successGreen)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 8) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(ColorTokens.dangerRed)
                                            
                                            Text("Pengeluaran")
                                                .font(TypographyTokens.captionSmall)
                                                .foregroundColor(ColorTokens.textSecondary)
                                        }
                                        
                                        Text(formatCurrency(viewModel.getTotalExpense()))
                                            .font(TypographyTokens.titleMedium)
                                            .foregroundColor(ColorTokens.dangerRed)
                                    }
                                }
                                
                                // Security Status Badge
                                HStack(spacing: 8) {
                                    Image(systemName: "shield.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                    
                                    Text(viewModel.getSecurityStatus())
                                        .font(TypographyTokens.labelSmall)
                                }
                                .foregroundColor(ColorTokens.successGreen)
                                .padding(8)
                                .background(ColorTokens.successGreen.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Quick Action Buttons
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aksi Cepat")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textSecondary)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 12) {
                                QuickActionButton(
                                    icon: "plus.circle.fill",
                                    title: "Tambah",
                                    color: ColorTokens.neonGreen,
                                    action: { showAddTransaction = true }
                                )
                                
                                QuickActionButton(
                                    icon: "arrow.left.circle.fill",
                                    title: "Transfer",
                                    color: ColorTokens.primaryGreen,
                                    action: {}
                                )
                                
                                QuickActionButton(
                                    icon: "chart.bar.fill",
                                    title: "Analisis",
                                    color: ColorTokens.warningYellow,
                                    action: {}
                                )
                                
                                QuickActionButton(
                                    icon: "sparkles",
                                    title: "AI",
                                    color: ColorTokens.neonGreen,
                                    action: { showAIChat = true }
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Recent Transactions Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Transaksi Terbaru")
                                    .font(TypographyTokens.headlineSmall)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                Spacer()
                                
                                NavigationLink(destination: TransactionScreen()) {
                                    HStack(spacing: 4) {
                                        Text("Lihat Semua")
                                            .font(TypographyTokens.labelSmall)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(ColorTokens.neonGreen)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            if viewModel.recentTransactions.isEmpty {
                                EmptyStateView(
                                    icon: "list.bullet.rectangle",
                                    title: "Belum Ada Transaksi",
                                    message: "Mulai catat transaksi Anda untuk melihat ringkasan di sini",
                                    actionTitle: "Tambah Transaksi",
                                    action: { showAddTransaction = true }
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
            
            // Floating AI Button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    FloatingAIButton(action: { showAIChat = true })
                        .padding(20)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // AI Chat Popup
            AIChatPopup(isPresented: $showAIChat, messages: $chatMessages)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionSheet(viewModel: TransactionViewModel(), isPresented: $showAddTransaction)
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

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(color.opacity(0.1))
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                .frame(height: 48)
                
                Text(title)
                    .font(TypographyTokens.captionSmall)
                    .foregroundColor(ColorTokens.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
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
