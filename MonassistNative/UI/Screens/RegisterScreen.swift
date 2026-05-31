import SwiftUI

struct RegisterScreen: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var agreeToTerms = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
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
                    Text("Buat Akun")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Daftar untuk memulai")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 32)
                
                // Form
                ScrollView {
                    VStack(spacing: 16) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nama Lengkap")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                
                                TextField("Masukkan nama", text: $name)
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                            )
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                
                                TextField("Masukkan email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                
                                if showPassword {
                                    TextField("Minimal 8 karakter", text: $password)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Minimal 8 karakter", text: $password)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                            )
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Konfirmasi Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                
                                if showConfirmPassword {
                                    TextField("Ulangi password", text: $confirmPassword)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Ulangi password", text: $confirmPassword)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                            )
                        }
                        
                        // Terms & Conditions
                        HStack(spacing: 10) {
                            Button(action: { agreeToTerms.toggle() }) {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 16))
                                    .foregroundColor(agreeToTerms ? Color(red: 0.4, green: 0.8, blue: 0.6) : .gray)
                            }
                            
                            HStack(spacing: 4) {
                                Text("Saya setuju dengan")
                                    .foregroundColor(.gray)
                                
                                Button(action: {}) {
                                    Text("Syarat & Ketentuan")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                                }
                            }
                            
                            Spacer()
                        }
                        .font(.system(size: 13))
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Register Button
                VStack(spacing: 16) {
                    Button(action: handleRegister) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Daftar")
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
                    .disabled(isLoading || !agreeToTerms)
                    .opacity(!agreeToTerms ? 0.5 : 1)
                    
                    // Login Link
                    HStack(spacing: 4) {
                        Text("Sudah punya akun?")
                            .foregroundColor(.gray)
                        
                        Button(action: { dismiss() }) {
                            Text("Masuk sekarang")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                        }
                    }
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(false)
    }
    
    private func handleRegister() {
        guard !name.isEmpty else {
            errorMessage = "Nama harus diisi"
            showError = true
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Email harus diisi"
            showError = true
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password minimal 8 karakter"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Password tidak cocok"
            showError = true
            return
        }
        
        guard agreeToTerms else {
            errorMessage = "Anda harus menyetujui syarat & ketentuan"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                let response = try await AuthService.shared.register(
                    name: name,
                    email: email,
                    password: password
                )
                isLoading = false
                
                if response["success"] as? Bool == true {
                    dismiss()
                } else {
                    errorMessage = response["message"] as? String ?? "Pendaftaran gagal"
                    showError = true
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterScreen()
    }
}
