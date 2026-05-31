import SwiftUI

struct BuatinScreen: View {
    @StateObject private var viewModel = AIViewModel()
    @State private var prompt = ""
    @State private var showResult = false
    @State private var generatedTransaction: [String: Any]?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Buatin Transaksi")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Biarkan AI membuat transaksi untuk Anda")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Input Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Deskripsi Transaksi")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $prompt)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                            
                            Text("Contoh: 'Beli makan siang di restoran ABC sebesar 50 ribu'")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        // Quick Templates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Template Cepat")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 8) {
                                QuickTemplateButton(
                                    icon: "🍔",
                                    title: "Makan",
                                    action: { prompt = "Makan siang di restoran" }
                                )
                                
                                QuickTemplateButton(
                                    icon: "🚕",
                                    title: "Transportasi",
                                    action: { prompt = "Naik taksi/ojek" }
                                )
                                
                                QuickTemplateButton(
                                    icon: "🛍️",
                                    title: "Belanja",
                                    action: { prompt = "Belanja kebutuhan" }
                                )
                                
                                QuickTemplateButton(
                                    icon: "💰",
                                    title: "Pemasukan",
                                    action: { prompt = "Pemasukan dari pekerjaan" }
                                )
                            }
                        }
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI akan menganalisis deskripsi Anda")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("dan membuat transaksi otomatis dengan kategori yang tepat")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(red: 0.1, green: 0.25, blue: 0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                
                Spacer()
                
                // Generate Button
                VStack(spacing: 12) {
                    Button(action: handleGenerate) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Buatin Sekarang")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.8, blue: 0.6),
                                Color(red: 0.3, green: 0.7, blue: 0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(isLoading || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(isLoading || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showResult) {
            if let transaction = generatedTransaction {
                BuatinResultSheet(transaction: transaction, isPresented: $showResult)
            }
        }
    }
    
    private func handleGenerate() {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        Task {
            let result = await viewModel.generateTransaction(prompt: prompt)
            isLoading = false
            
            if let result = result {
                generatedTransaction = result
                showResult = true
            }
        }
    }
}

struct QuickTemplateButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color(red: 0.12, green: 0.12, blue: 0.22))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
            )
        }
    }
}

struct BuatinResultSheet: View {
    let transaction: [String: Any]
    @Binding var isPresented: Bool
    @State private var isSaving = false
    
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Hasil Analisis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(red: 0.08, green: 0.08, blue: 0.18))
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Transaction Details
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction["title"] as? String ?? "Transaksi")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(transaction["merchant"] as? String ?? "")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    let amount = transaction["amount"] as? Double ?? 0
                                    Text("Rp \(Int(amount)):,")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                                    
                                    Text(transaction["type"] as? String ?? "expense")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Divider()
                                .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                            
                            // Details Grid
                            VStack(spacing: 12) {
                                DetailRow(
                                    label: "Kategori",
                                    value: transaction["category"] as? String ?? "-"
                                )
                                
                                DetailRow(
                                    label: "Metode Pembayaran",
                                    value: transaction["payment_method"] as? String ?? "-"
                                )
                                
                                DetailRow(
                                    label: "Tanggal",
                                    value: transaction["date"] as? String ?? "-"
                                )
                                
                                if let note = transaction["note"] as? String, !note.isEmpty {
                                    DetailRow(
                                        label: "Catatan",
                                        value: note
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: handleSave) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Simpan Transaksi")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.8, blue: 0.6),
                                Color(red: 0.3, green: 0.7, blue: 0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(isSaving)
                    
                    Button(action: { isPresented = false }) {
                        Text("Batal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func handleSave() {
        isSaving = true
        // TODO: Save transaction to backend
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isSaving = false
            isPresented = false
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    BuatinScreen()
}
