import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    
    @Binding var showCreateModal: Bool
    @State private var isIncomeModal = false
    @State private var showLocalSuccessToast = false
    
    // Create new transaction states
    @State private var newAmount = ""
    @State private var newDescription = ""
    @State private var selectedCategoryId = 1
    @State private var transactionNotes = ""
    @State private var transactionDate = Date()
    
    public init(showCreateModal: Binding<Bool>) {
        self._showCreateModal = showCreateModal
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 1. Balance Premium Glass Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SALDO AKTIF")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .tracking(1.5)
                                        .foregroundStyle(.white.opacity(0.6))
                                    
                                    Text("Rp \(formatAmount(transactionVM.totalBalance))")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                Image(systemName: "creditcard.fill")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PENGGUNA")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1.0)
                                        .foregroundStyle(.white.opacity(0.5))
                                    Text(authVM.currentUser?.name ?? "Teman Monassist")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                }
                                
                                Spacer()
                                
                                Text("Premium Member")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background {
                            // Sleek glassmorphism overlay using iOS 26 glass effect
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient(
                                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        .glassEffect(.regular.tint(.white.opacity(0.08)), in: RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .blue.opacity(0.15), radius: 20, y: 10)
                        
                        // 2. Rapid Actions Panel
                        HStack(spacing: 16) {
                            Button(action: {
                                isIncomeModal = true
                                newAmount = ""
                                newDescription = ""
                                selectedCategoryId = transactionVM.categories.first(where: { $0.isIncome })?.id ?? 4
                                transactionNotes = ""
                                showCreateModal = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.left.circle.fill")
                                        .font(.title3)
                                    Text("Uang Masuk")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(.white)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                            }
                            .tint(.green)
                            .glassEffect(in: Capsule())
                            
                            Button(action: {
                                isIncomeModal = false
                                newAmount = ""
                                newDescription = ""
                                selectedCategoryId = transactionVM.categories.first(where: { $0.isExpense })?.id ?? 1
                                transactionNotes = ""
                                showCreateModal = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.right.circle.fill")
                                        .font(.title3)
                                    Text("Uang Keluar")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(.white)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                            }
                            .tint(.red)
                            .glassEffect(in: Capsule())
                        }
                        
                        // 3. Mini Income & Expense Summary Cards
                        HStack(spacing: 16) {
                            // Income Box
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Pemasukan", systemImage: "arrow.down.left.circle")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Text("Rp \(formatAmount(transactionVM.totalIncome))")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                            
                            // Expense Box
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Pengeluaran", systemImage: "arrow.up.right.circle")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                Text("Rp \(formatAmount(transactionVM.totalExpense))")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // 4. Budget Progress Bars
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Batas Anggaran Bulanan")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            ForEach(transactionVM.categories.filter { $0.budgetLimit != nil }, id: \.id) { cat in
                                let spent = transactionVM.expenseByCategory[cat.name] ?? 0.0
                                let limit = cat.budgetLimit ?? 1.0
                                let ratio = min(spent / limit, 1.0)
                                let barColor = ratio > 0.85 ? Color.red : ratio > 0.6 ? Color.orange : Color.blue
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Label(cat.name, systemImage: cat.icon ?? "creditcard")
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text("\(Int(ratio * 100))%")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(barColor)
                                    }
                                    
                                    // Progress bar
                                    GeometryReader { barGeo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.white.opacity(0.15))
                                                .frame(height: 8)
                                            
                                            Capsule()
                                                .fill(barColor)
                                                .frame(width: barGeo.size.width * ratio, height: 8)
                                                .shadow(color: barColor.opacity(0.4), radius: 4)
                                        }
                                    }
                                    .frame(height: 8)
                                    
                                    HStack {
                                        Text("Rp \(formatAmount(spent))")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("Limit Rp \(formatAmount(limit))")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                                .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        
                        // 5. Pinned Recent Transactions List
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Transaksi Terbaru")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            
                            ForEach(transactionVM.transactions.prefix(4), id: \.id) { tx in
                                HStack(spacing: 16) {
                                    // Icon wrapper
                                    let catColorHex = transactionVM.categories.first(where: { $0.id == tx.categoryId })?.color ?? "#9CA3AF"
                                    let uiColor = Color(hex: catColorHex) ?? .gray
                                    
                                    Image(systemName: tx.isIncome ? "arrow.down.left" : "arrow.up.right")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding(10)
                                        .background(uiColor.opacity(0.8))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tx.description)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Text(tx.category?.name ?? "Lainnya")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(tx.formattedAmount)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(tx.isIncome ? Color.green : Color.white)
                                }
                                .padding()
                                .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        
                        Spacer().frame(height: 80)
                    }
                    .padding(20)
                }
                
                // Toast notification for offline success
                if showLocalSuccessToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Transaksi berhasil dicatat!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .glassEffect(in: Capsule())
                        .shadow(color: .black.opacity(0.3), radius: 10)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: showLocalSuccessToast)
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await transactionVM.loadData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.white)
                    }
                }
            }
            // Add Transaction Sheet Modal
            .sheet(isPresented: $showCreateModal) {
                NavigationStack {
                    ZStack {
                        Color(red: 0.08, green: 0.08, blue: 0.12)
                            .ignoresSafeArea()
                        
                        Form {
                            Section(header: Text("Jumlah & Deskripsi")) {
                                HStack {
                                    Text("Rp")
                                        .fontWeight(.bold)
                                    TextField("0", text: $newAmount)
                                        .keyboardType(.numberPad)
                                }
                                TextField("Deskripsi transaksi", text: $newDescription)
                            }
                            
                            Section(header: Text("Detail Tambahan")) {
                                Picker("Kategori", selection: $selectedCategoryId) {
                                    let list = transactionVM.categories.filter { isIncomeModal ? $0.isIncome : $0.isExpense }
                                    ForEach(list, id: \.id) { cat in
                                        Text(cat.name).tag(cat.id)
                                    }
                                }
                                
                                DatePicker("Tanggal", selection: $transactionDate, displayedComponents: .date)
                                
                                TextField("Catatan tambahan", text: $transactionNotes)
                            }
                        }
                        .formStyle(.grouped) // Beautiful grouped iOS 26 form factor!
                    }
                    .navigationTitle(isIncomeModal ? "Catat Uang Masuk" : "Catat Uang Keluar")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Batal") {
                                showCreateModal = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Simpan") {
                                if let amountDouble = Double(newAmount), !newDescription.isEmpty {
                                    Task {
                                        let success = await transactionVM.addTransaction(
                                            categoryId: selectedCategoryId,
                                            type: isIncomeModal ? "income" : "expense",
                                            amount: amountDouble,
                                            description: newDescription,
                                            date: transactionDate,
                                            notes: transactionNotes.isEmpty ? nil : transactionNotes
                                        )
                                        if success {
                                            showCreateModal = false
                                            withAnimation {
                                                showLocalSuccessToast = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                withAnimation {
                                                    showLocalSuccessToast = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
}

// Extends Color to support HEX conversion cleanly
extension Color {
    init?(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if cString.count != 6 {
            return nil
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
