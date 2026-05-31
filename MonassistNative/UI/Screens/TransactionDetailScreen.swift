import SwiftUI

public struct TransactionDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    let transaction: TransactionModel
    let category: CategoryModel?
    
    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    
    public init(transaction: TransactionModel, category: CategoryModel? = nil) {
        self.transaction = transaction
        self.category = category
    }
    
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ColorTokens.neonGreen)
                    }
                    
                    Spacer()
                    
                    Text("Detail Transaksi")
                        .font(TypographyTokens.headlineSmall)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { showEditSheet = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ColorTokens.neonGreen)
                    }
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Amount Display
                        LiquidGlassCard(cornerRadius: 28, padding: 24, showGlow: true) {
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(transaction.isIncome ? ColorTokens.successGreen : ColorTokens.dangerRed)
                                    
                                    Text(transaction.isIncome ? "Pemasukan" : "Pengeluaran")
                                        .font(TypographyTokens.labelSmall)
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                                
                                Text(formatCurrency(transaction.amount))
                                    .font(TypographyTokens.displaySmall)
                                    .foregroundColor(transaction.isIncome ? ColorTokens.successGreen : ColorTokens.dangerRed)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal, 16)
                        
                        // Transaction Details
                        VStack(spacing: 12) {
                            TransactionDetailRow(
                                icon: "tag.fill",
                                label: "Kategori",
                                value: category?.name ?? "Tidak Diketahui",
                                color: category?.colorValue ?? ColorTokens.primaryGreen
                            )
                            
                            TransactionDetailRow(
                                icon: "calendar",
                                label: "Tanggal",
                                value: formatDate(transaction.transactionDate),
                                color: ColorTokens.neonGreen
                            )
                            
                            if let merchant = transaction.merchant {
                                TransactionDetailRow(
                                    icon: "building.2.fill",
                                    label: "Merchant",
                                    value: merchant,
                                    color: ColorTokens.primaryGreen
                                )
                            }
                            
                            if let paymentMethod = transaction.paymentMethod {
                                TransactionDetailRow(
                                    icon: "creditcard.fill",
                                    label: "Metode Pembayaran",
                                    value: paymentMethod.name,
                                    color: ColorTokens.warningYellow
                                )
                            }
                            
                            TransactionDetailRow(
                                icon: "doc.text.fill",
                                label: "Deskripsi",
                                value: transaction.title,
                                color: ColorTokens.neonGreen
                            )
                            
                            if let note = transaction.note, !note.isEmpty {
                                TransactionDetailRow(
                                    icon: "note.text",
                                    label: "Catatan",
                                    value: note,
                                    color: ColorTokens.primaryGreen
                                )
                            }
                            
                            if let location = transaction.locationName {
                                TransactionDetailRow(
                                    icon: "location.fill",
                                    label: "Lokasi",
                                    value: location,
                                    color: ColorTokens.dangerRed
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Receipt Image (if available)
                        if let receiptUrl = transaction.receiptImageUrl, let url = URL(string: receiptUrl) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Bukti Transaksi")
                                    .font(TypographyTokens.labelMedium)
                                    .foregroundColor(ColorTokens.textSecondary)
                                    .padding(.horizontal, 16)
                                
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(16)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(ColorTokens.cardBackground)
                                        .frame(height: 200)
                                        .overlay(
                                            ProgressView()
                                                .tint(ColorTokens.neonGreen)
                                        )
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            LiquidGlassButton(
                                title: "Edit Transaksi",
                                icon: "pencil.circle.fill",
                                style: .primary,
                                action: { showEditSheet = true }
                            )
                            
                            LiquidGlassButton(
                                title: "Hapus Transaksi",
                                icon: "trash.circle.fill",
                                style: .danger,
                                action: { showDeleteConfirm = true }
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .alert("Hapus Transaksi", isPresented: $showDeleteConfirm) {
            Button("Batal", role: .cancel) {}
            Button("Hapus", role: .destructive) {
                // Delete action
                dismiss()
            }
        } message: {
            Text("Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.")
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp \(Int(amount))"
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Detail Row Component
struct TransactionDetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        LiquidGlassCard(cornerRadius: 16, padding: 12, showGlow: false) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
                .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(TypographyTokens.captionSmall)
                        .foregroundColor(ColorTokens.textSecondary)
                    
                    Text(value)
                        .font(TypographyTokens.labelMedium)
                        .foregroundColor(ColorTokens.textPrimary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
    }
}

#if DEBUG
struct TransactionDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TransactionDetailScreen(
                transaction: TransactionModel(
                    id: 1,
                    userId: 1,
                    type: "expense",
                    title: "Makan Siang",
                    merchant: "Restoran ABC",
                    amount: 50000,
                    categoryId: 1,
                    paymentMethodId: 1,
                    note: "Makan dengan teman",
                    transactionDate: "2024-01-15T12:30:00",
                    receiptImageUrl: nil,
                    locationName: "Jakarta",
                    latitude: nil,
                    longitude: nil,
                    isFavorite: false,
                    isPinned: false,
                    createdAt: "2024-01-15T12:30:00",
                    updatedAt: "2024-01-15T12:30:00",
                    category: nil,
                    paymentMethod: nil
                )
            )
        }
        .preferredColorScheme(.dark)
    }
}
#endif
