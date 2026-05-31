import SwiftUI

public struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var isLogin = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var validationError: String?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Elegant Cosmic dark backdrop
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            // Cosmic organic light leaks
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                        .blur(radius: 60)
                        .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.1)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .blur(radius: 70)
                        .offset(x: geo.size.width * 0.3, y: -geo.size.height * 0.15)
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // Brand Logo
                    VStack(spacing: 12) {
                        Image(systemName: "creditcard.and.123")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .purple.opacity(0.3), radius: 15)
                        
                        Text("Monassist")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                        
                        Text("Asisten Finansial Pintar Anda")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Main Glass Card
                    VStack(spacing: 24) {
                        // Custom segment selector (Login / Register)
                        HStack(spacing: 4) {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isLogin = true
                                    validationError = nil
                                }
                            }) {
                                Text("Masuk")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(isLogin ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background {
                                        if isLogin {
                                            Capsule()
                                                .fill(Color.white.opacity(0.08))
                                                .matchedGeometryEffect(id: "activeTab", in: authTabsNamespace)
                                        }
                                    }
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isLogin = false
                                    validationError = nil
                                }
                            }) {
                                Text("Daftar")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(!isLogin ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background {
                                        if !isLogin {
                                            Capsule()
                                                .fill(Color.white.opacity(0.08))
                                                .matchedGeometryEffect(id: "activeTab", in: authTabsNamespace)
                                        }
                                    }
                            }
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.03))
                        .clipShape(Capsule())
                        
                        // Input Fields Stack
                        VStack(spacing: 16) {
                            if !isLogin {
                                // Full Name
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.secondary)
                                    TextField("Nama Lengkap", text: $name)
                                        .textContentType(.name)
                                        .autocorrectionDisabled()
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .glassEffect(in: Capsule())
                            }
                            
                            // Email Address
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.secondary)
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .glassEffect(in: Capsule())
                            
                            // Password
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                                
                                if showPassword {
                                    TextField("Kata Sandi", text: $password)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .foregroundStyle(.white)
                                } else {
                                    SecureField("Kata Sandi", text: $password)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .foregroundStyle(.white)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .glassEffect(in: Capsule())
                            
                            if !isLogin {
                                // Password confirmation
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundStyle(.secondary)
                                    SecureField("Konfirmasi Kata Sandi", text: $confirmPassword)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .glassEffect(in: Capsule())
                            }
                        }
                        
                        // Error Messages
                        if let error = validationError ?? authVM.errorMessage {
                            Text(error)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Submit Button
                        Button(action: {
                            Task {
                                await handleAuthSubmit()
                            }
                        }) {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isLogin ? "Masuk ke Akun" : "Buat Akun Baru")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "arrow.right")
                                        .fontWeight(.bold)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .tint(isLogin ? .blue : .purple)
                        .glassEffect(in: Capsule())
                        .disabled(authVM.isLoading)
                    }
                    .padding(24)
                    // High-quality outer glass card representing the auth panel
                    .glassEffect(.regular.tint(.white.opacity(0.05)), in: RoundedRectangle(cornerRadius: 32))
                    .padding(.horizontal, 20)
                    
                    // Auxiliary login options
                    VStack(spacing: 16) {
                        Text("atau masuk menggunakan")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 20) {
                            Button(action: {}) {
                                Image(systemName: "apple.logo")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .glassEffect(in: Circle())
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "bubble.right.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .glassEffect(in: Circle())
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    @Namespace private var authTabsNamespace
    
    private func handleAuthSubmit() async {
        validationError = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty && !trimmedPassword.isEmpty else {
            validationError = "Email dan kata sandi tidak boleh kosong."
            return
        }
        
        if isLogin {
            _ = await authVM.login(email: trimmedEmail, password: trimmedPassword)
        } else {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                validationError = "Nama lengkap harus diisi."
                return
            }
            guard trimmedPassword.count >= 6 else {
                validationError = "Kata sandi minimal 6 karakter."
                return
            }
            guard trimmedPassword == confirmPassword else {
                validationError = "Kata sandi konfirmasi tidak cocok."
                return
            }
            
            _ = await authVM.register(name: trimmedName, email: trimmedEmail, password: trimmedPassword)
        }
    }
}
