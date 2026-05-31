import SwiftUI

public struct TransactionHistoryView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel
    
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showFilterSheet = false
    @State private var deleteTargetId: Int?
    
    enum TransactionFilter: String, CaseIterable {
        case all = "Semua"
        case income = "Pemasukan"
        case expense = "Pengeluaran"
    }
    
    var filteredTransactions: [TransactionModel] {
        var result = transactionVM.transactions
        
        switch selectedFilter {
        case .income:
            result = result.filter { $0.isIncome }
        case .expense:
            result = result.filter { $0.isExpense }
        case .all:
            break
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                ($0.category?.name ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(TransactionFilter.allCases, id: \.self) { filter in
                                Button(action: {
                                    withAnimation(.spring(response: 0.35)) {
                                        selectedFilter = filter
                                    }
                                }) {
                                    Text(filter.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(selectedFilter == filter ? .bold : .regular)
                                        .foregroundStyle(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                }
                                .tint(selectedFilter == filter ? .blue : .clear)
                                .glassEffect(in: Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    if filteredTransactions.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 56))
                                .foregroundStyle(.secondary)
                            Text("Tidak ada transaksi ditemukan")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(groupedByDate.keys.sorted(by: >), id: \.self) { dateKey in
                                Section(header: Text(dateKey)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                ) {
                                    ForEach(groupedByDate[dateKey] ?? [], id: \.id) { tx in
                                        TransactionRowView(transaction: tx, categories: transactionVM.categories)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    Task {
                                                        _ = await transactionVM.deleteTransaction(tx.id)
                                                    }
                                                } label: {
                                                    Label("Hapus", systemImage: "trash")
                                                }
                                            }
                                            .listRowBackground(Color.white.opacity(0.04))
                                            .listRowSeparatorTint(Color.white.opacity(0.08))
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Transaksi")
            .searchable(text: $searchText, prompt: "Cari transaksi...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if transactionVM.isLoading {
                        ProgressView().tint(.white)
                    }
                }
            }
            .refreshable {
                await transactionVM.loadData()
            }
        }
    }
    
    private var groupedByDate: [String: [TransactionModel]] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "id_ID")
        return Dictionary(grouping: filteredTransactions) { tx in
            formatter.string(from: tx.transactionDate)
        }
    }
}

struct TransactionRowView: View {
    let transaction: TransactionModel
    let categories: [CategoryModel]
    
    private var categoryColor: Color {
        let hex = categories.first(where: { $0.id == transaction.categoryId })?.color ?? "#6B7280"
        return Color(hex: hex) ?? .gray
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Circle category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.isIncome ? "arrow.down.left" : "arrow.up.right")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(transaction.isIncome ? .green : categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(transaction.category?.name ?? "Lainnya")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(notes)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(transaction.isIncome ? .green : .white)
        }
        .padding(.vertical, 4)
    }
}
