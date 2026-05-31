import SwiftUI

struct LoginScreen: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
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
                    Text("Selamat Datang")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Masuk ke akun Anda")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 40)
                
                // Form
                VStack(spacing: 20) {
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
                                TextField("Masukkan password", text: $password)
                                    .foregroundColor(.white)
                            } else {
                                SecureField("Masukkan password", text: $password)
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
                    
                    // Remember & Forgot
                    HStack {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "square")
                                    .font(.system(size: 14))
                                Text("Ingat saya")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Lupa password?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Login Button
                VStack(spacing: 16) {
                    Button(action: handleLogin) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Masuk")
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
                    .disabled(isLoading)
                    
                    // Register Link
                    HStack(spacing: 4) {
                        Text("Belum punya akun?")
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: RegisterScreen()) {
                            Text("Daftar sekarang")
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
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email dan password harus diisi"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                let response = try await AuthService.shared.login(email: email, password: password)
                isLoading = false
                
                if response["success"] as? Bool == true {
                    dismiss()
                } else {
                    errorMessage = response["message"] as? String ?? "Login gagal"
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
        LoginScreen()
    }
}
