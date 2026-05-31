import SwiftUI

public struct TransactionScreen: View {
    @StateObject private var viewModel = TransactionViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showFilterSheet = false
    @State private var showAddTransaction = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Transaksi")
                            .font(TypographyTokens.headlineLarge)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Spacer()
                        
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ColorTokens.neonGreen)
                        }
                    }
                    
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(ColorTokens.textSecondary)
                        
                        TextField("Cari transaksi...", text: $viewModel.searchText)
                            .font(TypographyTokens.bodySmall)
                            .foregroundColor(ColorTokens.textPrimary)
                            .onChange(of: viewModel.searchText) { _ in
                                viewModel.applyFilters()
                            }
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                                viewModel.applyFilters()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(ColorTokens.textSecondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(ColorTokens.cardBackground)
                    .cornerRadius(10)
                }
                .padding(16)
                
                // Monthly Summary
                if let summary = viewModel.monthlySummary {
                    LiquidGlassCard(cornerRadius: 16, padding: 12) {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bulan Ini")
                                    .font(TypographyTokens.captionSmall)
                                    .foregroundColor(ColorTokens.textSecondary)
                                
                                Text(formatCurrency(summary.netBalance))
                                    .font(TypographyTokens.titleMedium)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 8) {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Masuk")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(summary.totalIncome))
                                            .font(TypographyTokens.labelMedium)
                                            .foregroundColor(ColorTokens.successGreen)
                                    }
                                    
                                    Divider()
                                        .frame(height: 30)
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Keluar")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(formatCurrency(summary.totalExpense))
                                            .font(TypographyTokens.labelMedium)
                                            .foregroundColor(ColorTokens.dangerRed)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                
                // Transactions List
                if viewModel.isLoading {
                    LoadingSkeletonView()
                        .padding(16)
                } else if let error = viewModel.errorMessage {
                    ErrorStateView(message: error) {
                        Task {
                            await viewModel.loadTransactions()
                        }
                    }
                } else if viewModel.filteredTransactions.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet.rectangle",
                        title: "Belum Ada Transaksi",
                        message: "Mulai catat transaksi Anda untuk melihat riwayat di sini",
                        actionTitle: "Tambah Transaksi",
                        action: { showAddTransaction = true }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            let grouped = viewModel.groupTransactionsByDate()
                            let sortedDates = grouped.keys.sorted().reversed()
                            
                            ForEach(sortedDates, id: \.self) { date in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(formatDate(date))
                                        .font(TypographyTokens.labelMedium)
                                        .foregroundColor(ColorTokens.textSecondary)
                                        .padding(.horizontal, 16)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(grouped[date] ?? []) { transaction in
                                            TransactionCard(
                                                transaction: transaction,
                                                category: viewModel.categories.first { $0.id == transaction.categoryId }
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
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionSheet(viewModel: viewModel, isPresented: $showAddTransaction)
        }
        .task {
            await viewModel.loadTransactions()
            await viewModel.loadCategories()
            await viewModel.loadPaymentMethods()
            await viewModel.loadMonthlySummary()
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
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Filter Transaksi")
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
                    VStack(alignment: .leading, spacing: 16) {
                        // Type Filter
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipe Transaksi")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            HStack(spacing: 8) {
                                ForEach(["income", "expense"], id: \.self) { type in
                                    Button(action: {
                                        viewModel.selectedType = viewModel.selectedType == type ? nil : type
                                        viewModel.applyFilters()
                                    }) {
                                        Text(type == "income" ? "Pemasukan" : "Pengeluaran")
                                            .font(TypographyTokens.labelSmall)
                                            .foregroundColor(viewModel.selectedType == type ? .white : ColorTokens.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .padding(10)
                                            .background(viewModel.selectedType == type ? ColorTokens.primaryGreen : ColorTokens.cardBackground)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Category Filter
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kategori")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.categories) { category in
                                        Button(action: {
                                            viewModel.selectedCategory = viewModel.selectedCategory == category.id ? nil : category.id
                                            viewModel.applyFilters()
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: category.icon)
                                                Text(category.name)
                                            }
                                            .font(TypographyTokens.labelSmall)
                                            .foregroundColor(viewModel.selectedCategory == category.id ? .white : ColorTokens.textSecondary)
                                            .padding(8)
                                            .background(viewModel.selectedCategory == category.id ? category.colorValue : ColorTokens.cardBackground)
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                
                // Clear & Apply Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.clearFilters()
                    }) {
                        Text("Hapus Filter")
                            .font(TypographyTokens.labelMedium)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(ColorTokens.cardBackground)
                            .foregroundColor(ColorTokens.textPrimary)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Terapkan")
                            .font(TypographyTokens.labelMedium)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(ColorTokens.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Add Transaction Sheet
struct AddTransactionSheet: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var isPresented: Bool
    
    @State private var transactionType = "expense"
    @State private var title = ""
    @State private var merchant = ""
    @State private var amount = ""
    @State private var selectedCategory: Int?
    @State private var selectedPaymentMethod: Int?
    @State private var note = ""
    @State private var transactionDate = Date()
    
    var body: some View {
        ZStack {
            ColorTokens.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Tambah Transaksi")
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
                        // Type Selection
                        Picker("Tipe", selection: $transactionType) {
                            Text("Pengeluaran").tag("expense")
                            Text("Pemasukan").tag("income")
                        }
                        .pickerStyle(.segmented)
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nominal")
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            TextField("0", text: $amount)
                                .font(TypographyTokens.monospaceMedium)
                                .foregroundColor(ColorTokens.textPrimary)
                                .keyboardType(.decimalPad)
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
                            isPresented = false
                        }
                    }
                )
                .padding(16)
            }
        }
    }
}

#if DEBUG
struct TransactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TransactionScreen()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
