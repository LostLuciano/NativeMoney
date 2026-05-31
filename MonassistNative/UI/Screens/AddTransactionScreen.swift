import SwiftUI

public struct AddTransactionScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TransactionViewModel()
    
    @State private var transactionType = "expense"
    @State private var title = ""
    @State private var merchant = ""
    @State private var amount = ""
    @State private var selectedCategory: Int?
    @State private var selectedPaymentMethod: Int?
    @State private var note = ""
    @State private var transactionDate = Date()
    @State private var selectedMode: AddMode = .manual
    
    enum AddMode {
        case manual
        case scanReceipt
        case voiceInput
        case importCSV
    }
    
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ColorTokens.neonGreen)
                    }
                    
                    Spacer()
                    
                    Text("Tambah Transaksi")
                        .font(TypographyTokens.headlineSmall)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                .padding(16)
                
                // Mode Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Metode Input")
                        .font(TypographyTokens.labelMedium)
                        .foregroundColor(ColorTokens.textSecondary)
                        .padding(.horizontal, 16)
                    
                    HStack(spacing: 8) {
                        ModeButton(
                            icon: "pencil.circle.fill",
                            title: "Manual",
                            isSelected: selectedMode == .manual,
                            action: { selectedMode = .manual }
                        )
                        
                        ModeButton(
                            icon: "camera.circle.fill",
                            title: "Scan",
                            isSelected: selectedMode == .scanReceipt,
                            action: { selectedMode = .scanReceipt }
                        )
                        
                        ModeButton(
                            icon: "mic.circle.fill",
                            title: "Suara",
                            isSelected: selectedMode == .voiceInput,
                            action: { selectedMode = .voiceInput }
                        )
                        
                        ModeButton(
                            icon: "doc.circle.fill",
                            title: "CSV",
                            isSelected: selectedMode == .importCSV,
                            action: { selectedMode = .importCSV }
                        )
                    }
                    .padding(.horizontal, 16)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Type Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipe Transaksi")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            Picker("Tipe", selection: $transactionType) {
                                Text("Pengeluaran").tag("expense")
                                Text("Pemasukan").tag("income")
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nominal")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            HStack(spacing: 8) {
                                Text("Rp")
                                    .font(TypographyTokens.monospaceMedium)
                                    .foregroundColor(ColorTokens.textSecondary)
                                
                                TextField("0", text: $amount)
                                    .font(TypographyTokens.monospaceMedium)
                                    .foregroundColor(ColorTokens.textPrimary)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(12)
                            .background(ColorTokens.cardBackground)
                            .cornerRadius(10)
                        }
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deskripsi")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            TextField("Contoh: Makan siang", text: $title)
                                .font(TypographyTokens.bodySmall)
                                .foregroundColor(ColorTokens.textPrimary)
                                .padding(12)
                                .background(ColorTokens.cardBackground)
                                .cornerRadius(10)
                        }
                        
                        // Merchant
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Merchant (Opsional)")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            TextField("Contoh: Restoran ABC", text: $merchant)
                                .font(TypographyTokens.bodySmall)
                                .foregroundColor(ColorTokens.textPrimary)
                                .padding(12)
                                .background(ColorTokens.cardBackground)
                                .cornerRadius(10)
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kategori")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.categories.filter { $0.type == transactionType }) { category in
                                        Button(action: { selectedCategory = category.id }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: category.icon)
                                                    .font(.system(size: 16))
                                                Text(category.name)
                                                    .font(TypographyTokens.captionSmall)
                                            }
                                            .frame(width: 60)
                                            .padding(8)
                                            .background(selectedCategory == category.id ? category.colorValue : ColorTokens.cardBackground)
                                            .foregroundColor(selectedCategory == category.id ? .white : ColorTokens.textSecondary)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Payment Method
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Metode Pembayaran")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            Picker("Metode", selection: $selectedPaymentMethod) {
                                Text("Pilih Metode").tag(Int?(nil))
                                ForEach(viewModel.paymentMethods) { method in
                                    Text(method.name).tag(Int?(method.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(ColorTokens.cardBackground)
                            .cornerRadius(10)
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            DatePicker("", selection: $transactionDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }
                        
                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Catatan (Opsional)")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            TextEditor(text: $note)
                                .font(TypographyTokens.bodySmall)
                                .foregroundColor(ColorTokens.textPrimary)
                                .frame(height: 80)
                                .padding(12)
                                .background(ColorTokens.cardBackground)
                                .cornerRadius(10)
                        }
                    }
                    .padding(16)
                }
                
                // Save Button
                LiquidGlassButton(
                    title: "Simpan Transaksi",
                    icon: "checkmark",
                    style: .primary,
                    action: {
                        guard let amountValue = Double(amount), !title.isEmpty, let categoryId = selectedCategory else { return }
                        
                        let formatter = ISO8601DateFormatter()
                        let dateString = formatter.string(from: transactionDate)
                        
                        Task {
                            await viewModel.createTransaction(
                                type: transactionType,
                                title: title,
                                merchant: merchant.isEmpty ? nil : merchant,
                                amount: amountValue,
                                categoryId: categoryId,
                                paymentMethodId: selectedPaymentMethod,
                                note: note.isEmpty ? nil : note,
                                transactionDate: dateString,
                                locationName: nil
                            )
                            dismiss()
                        }
                    }
                )
                .padding(16)
            }
        }
        .task {
            await viewModel.loadCategories()
            await viewModel.loadPaymentMethods()
        }
    }
}

// MARK: - Mode Button
struct ModeButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(title)
                    .font(TypographyTokens.captionSmall)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(isSelected ? ColorTokens.neonGreen.opacity(0.2) : ColorTokens.cardBackground)
            .foregroundColor(isSelected ? ColorTokens.neonGreen : ColorTokens.textSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ColorTokens.neonGreen : Color.clear, lineWidth: 2)
            )
        }
    }
}

#if DEBUG
struct AddTransactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddTransactionScreen()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
