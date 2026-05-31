import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showLogoutConfirm = false
    @State private var showTelegramSheet = false
    @State private var telegramCode: String?
    @State private var isLoadingTelegram = false
    @State private var showChangePassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var passwordError: String?
    @State private var showSuccessToast = false
    @State private var toastMessage = ""
    
    // Profile edit states
    @State private var editName = ""
    @State private var editPhone = ""
    @State private var editBio = ""
    @State private var editCurrency = "IDR"
    @State private var isEditingProfile = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Header Card
                        VStack(spacing: 20) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 80, height: 80)
                                
                                Text(String((authVM.currentUser?.name ?? "U").prefix(1)).uppercased())
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: .blue.opacity(0.3), radius: 12)
                            
                            VStack(spacing: 4) {
                                Text(authVM.currentUser?.name ?? "Pengguna")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text(authVM.currentUser?.email ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                if let telegram = authVM.currentUser?.telegramId {
                                    Label("Telegram Terhubung (\(telegram))", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                        .padding(.top, 4)
                                }
                            }
                            
                            Button(action: {
                                editName = authVM.currentUser?.name ?? ""
                                editPhone = authVM.currentUser?.phone ?? ""
                                editBio = authVM.currentUser?.bio ?? ""
                                editCurrency = authVM.currentUser?.currency ?? "IDR"
                                isEditingProfile = true
                            }) {
                                Label("Edit Profil", systemImage: "pencil")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                            .glassEffect(in: Capsule())
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .glassEffect(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24))
                        
                        // Settings Groups
                        settingsSection(title: "Akun & Keamanan") {
                            settingsRow(icon: "lock.rotation", label: "Ubah Kata Sandi", tint: .blue) {
                                currentPassword = ""
                                newPassword = ""
                                confirmNewPassword = ""
                                passwordError = nil
                                showChangePassword = true
                            }
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            settingsRow(icon: "bell.fill", label: "Notifikasi", tint: .orange) {
                                // Toggle notifications
                            }
                        }
                        
                        settingsSection(title: "Integrasi") {
                            settingsRow(icon: "paperplane.fill", label: "Hubungkan Telegram", tint: .blue, detail: authVM.currentUser?.isTelegramConnected == true ? "Terhubung" : "Belum") {
                                showTelegramSheet = true
                            }
                        }
                        
                        settingsSection(title: "Preferensi") {
                            settingsRow(icon: "globe", label: "Mata Uang: \(authVM.currentUser?.currency ?? "IDR")", tint: .green) {
                                // Show currency picker
                            }
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            settingsRow(icon: "moon.fill", label: "Mode Gelap", tint: .indigo) {
                                // Toggle dark mode
                            }
                        }
                        
                        settingsSection(title: "Tentang") {
                            settingsRow(icon: "info.circle.fill", label: "Versi App: 1.0.0", tint: .gray) {}
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            settingsRow(icon: "doc.text.fill", label: "Kebijakan Privasi", tint: .gray) {}
                        }
                        
                        // Logout Button
                        Button(action: { showLogoutConfirm = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Keluar dari Akun")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(Color.red.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .tint(.red)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(20)
                }
                
                // Success toast
                if showSuccessToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text(toastMessage).fontWeight(.semibold).foregroundStyle(.white)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .glassEffect(in: Capsule())
                        .padding(.bottom, 80)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: showSuccessToast)
                }
            }
            .navigationTitle("Pengaturan")
            .confirmationDialog("Konfirmasi Keluar", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Keluar", role: .destructive) {
                    Task { await authVM.logout() }
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Apakah Anda yakin ingin keluar dari akun Monassist?")
            }
            // Edit Profile Sheet
            .sheet(isPresented: $isEditingProfile) {
                NavigationStack {
                    Form {
                        Section(header: Text("Informasi Dasar")) {
                            LabeledContent("Nama") {
                                TextField("Nama lengkap", text: $editName)
                                    .multilineTextAlignment(.trailing)
                            }
                            LabeledContent("Telepon") {
                                TextField("No. telepon", text: $editPhone)
                                    .keyboardType(.phonePad)
                                    .multilineTextAlignment(.trailing)
                            }
                            LabeledContent("Bio") {
                                TextField("Bio singkat", text: $editBio)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        Section(header: Text("Preferensi")) {
                            Picker("Mata Uang", selection: $editCurrency) {
                                Text("IDR").tag("IDR")
                                Text("USD").tag("USD")
                                Text("SGD").tag("SGD")
                                Text("MYR").tag("MYR")
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .navigationTitle("Edit Profil")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Batal") { isEditingProfile = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Simpan") {
                                Task {
                                    let success = await authVM.updateProfile(
                                        name: editName,
                                        phone: editPhone.isEmpty ? nil : editPhone,
                                        currency: editCurrency,
                                        bio: editBio.isEmpty ? nil : editBio
                                    )
                                    if success {
                                        isEditingProfile = false
                                        showToast("Profil berhasil diperbarui!")
                                    }
                                }
                            }
                            .disabled(authVM.isLoading)
                        }
                    }
                }
            }
            // Change Password Sheet
            .sheet(isPresented: $showChangePassword) {
                NavigationStack {
                    Form {
                        Section(header: Text("Ubah Kata Sandi")) {
                            SecureField("Kata sandi saat ini", text: $currentPassword)
                            SecureField("Kata sandi baru", text: $newPassword)
                            SecureField("Konfirmasi kata sandi baru", text: $confirmNewPassword)
                        }
                        
                        if let err = passwordError {
                            Section {
                                Text(err)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .navigationTitle("Ubah Kata Sandi")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Batal") { showChangePassword = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Simpan") {
                                passwordError = nil
                                guard newPassword.count >= 6 else {
                                    passwordError = "Kata sandi baru minimal 6 karakter."
                                    return
                                }
                                guard newPassword == confirmNewPassword else {
                                    passwordError = "Konfirmasi tidak cocok."
                                    return
                                }
                                Task {
                                    do {
                                        _ = try await AuthService.shared.changePassword(current: currentPassword, new: newPassword)
                                        showChangePassword = false
                                        showToast("Kata sandi berhasil diubah!")
                                    } catch {
                                        passwordError = error.localizedDescription
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // Telegram Connection Sheet
            .sheet(isPresented: $showTelegramSheet) {
                NavigationStack {
                    ZStack {
                        Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea()
                        
                        VStack(spacing: 32) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                                )
                            
                            VStack(spacing: 8) {
                                Text("Hubungkan Telegram")
                                    .font(.title2).fontWeight(.bold).foregroundStyle(.white)
                                
                                Text("Catat transaksi langsung via Telegram Bot. Ketikkan kode ini di bot @MonassistBot:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            if isLoadingTelegram {
                                ProgressView().tint(.white)
                            } else if let code = telegramCode {
                                Text(code)
                                    .font(.system(size: 36, weight: .black, design: .monospaced))
                                    .tracking(8)
                                    .foregroundStyle(.white)
                                    .padding(20)
                                    .glassEffect(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                            }
                            
                            if authVM.currentUser?.isTelegramConnected == true {
                                Button(action: {
                                    Task {
                                        do {
                                            _ = try await TelegramService.shared.disconnectTelegram()
                                            await authVM.fetchCurrentUser()
                                            showTelegramSheet = false
                                            showToast("Telegram berhasil diputuskan.")
                                        } catch {
                                            print("Disconnect error: \(error)")
                                        }
                                    }
                                }) {
                                    Label("Putuskan Telegram", systemImage: "xmark.circle")
                                        .foregroundStyle(Color.red.opacity(0.8))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                }
                                .tint(.red)
                                .glassEffect(in: Capsule())
                                .padding(.horizontal, 40)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 40)
                    }
                    .navigationTitle("Integrasi Telegram")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Selesai") { showTelegramSheet = false }
                        }
                    }
                    .task {
                        isLoadingTelegram = true
                        do {
                            let res = try await TelegramService.shared.generatePairingCode()
                            telegramCode = res["code"] as? String ?? res["pairing_code"] as? String
                        } catch {
                            telegramCode = "DEMO-1234"
                        }
                        isLoadingTelegram = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(.vertical, 4)
            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func settingsRow(icon: String, label: String, tint: Color, detail: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tint.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundStyle(tint)
                }
                
                Text(label)
                    .font(.body)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation { showSuccessToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSuccessToast = false }
        }
    }
}
