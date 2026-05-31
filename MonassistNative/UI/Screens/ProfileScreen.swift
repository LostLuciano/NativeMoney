import SwiftUI

public struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    
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
                    Text("Profil")
                        .font(TypographyTokens.headlineLarge)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                    
                    NavigationLink(destination: SettingsScreen()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ColorTokens.neonGreen)
                    }
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Card
                        LiquidGlassCard(cornerRadius: 20, padding: 20) {
                            VStack(spacing: 16) {
                                // Avatar
                                if let avatarUrl = viewModel.user?.avatarUrl, let url = URL(string: avatarUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(40)
                                    } placeholder: {
                                        Circle()
                                            .fill(ColorTokens.primaryGreen)
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Text(String(viewModel.user?.name.prefix(1) ?? "U"))
                                                    .font(TypographyTokens.displaySmall)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                } else {
                                    Circle()
                                        .fill(ColorTokens.primaryGreen)
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Text(String(viewModel.user?.name.prefix(1) ?? "U"))
                                                .font(TypographyTokens.displaySmall)
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.user?.name ?? "User")
                                        .font(TypographyTokens.headlineSmall)
                                        .foregroundColor(ColorTokens.textPrimary)
                                    
                                    Text(viewModel.user?.email ?? "")
                                        .font(TypographyTokens.bodySmall)
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                                
                                Divider()
                                    .background(ColorTokens.glassStroke.opacity(0.2))
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Status Akun")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text("Aktif")
                                            .font(TypographyTokens.labelMedium)
                                            .foregroundColor(ColorTokens.successGreen)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Mata Uang")
                                            .font(TypographyTokens.captionSmall)
                                            .foregroundColor(ColorTokens.textSecondary)
                                        
                                        Text(viewModel.user?.currency ?? "IDR")
                                            .font(TypographyTokens.labelMedium)
                                            .foregroundColor(ColorTokens.textPrimary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Menu Items
                        VStack(spacing: 8) {
                            ProfileMenuItem(
                                icon: "person.fill",
                                title: "Edit Profil",
                                subtitle: "Ubah informasi pribadi Anda"
                            )
                            
                            ProfileMenuItem(
                                icon: "creditcard.fill",
                                title: "Metode Pembayaran",
                                subtitle: "Kelola metode pembayaran"
                            )
                            
                            ProfileMenuItem(
                                icon: "tag.fill",
                                title: "Kategori",
                                subtitle: "Atur kategori transaksi"
                            )
                            
                            ProfileMenuItem(
                                icon: "target",
                                title: "Budget",
                                subtitle: "Kelola budget bulanan"
                            )
                            
                            ProfileMenuItem(
                                icon: "arrow.up.doc.fill",
                                title: "Export Data",
                                subtitle: "Unduh data transaksi Anda"
                            )
                            
                            ProfileMenuItem(
                                icon: "icloud.and.arrow.up.fill",
                                title: "Backup",
                                subtitle: "Backup data ke cloud"
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // Logout Button
                        LiquidGlassButton(
                            title: "Logout",
                            icon: "arrow.right.circle.fill",
                            style: .danger,
                            action: {
                                Task {
                                    await viewModel.logout()
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ColorTokens.neonGreen)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TypographyTokens.labelMedium)
                    .foregroundColor(ColorTokens.textPrimary)
                
                Text(subtitle)
                    .font(TypographyTokens.captionSmall)
                    .foregroundColor(ColorTokens.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ColorTokens.textSecondary)
        }
        .padding(12)
        .background(ColorTokens.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Settings Screen
public struct SettingsScreen: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("appTheme") var appTheme = "dark"
    @AppStorage("glassIntensity") var glassIntensity = 1.0
    @AppStorage("reduceTransparency") var reduceTransparency = false
    @AppStorage("enableHaptics") var enableHaptics = true
    @AppStorage("appLanguage") var appLanguage = "id"
    
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
                    
                    Text("Pengaturan")
                        .font(TypographyTokens.headlineLarge)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                }
                .padding(16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Appearance Section
                        SettingsSection(title: "Tampilan") {
                            VStack(spacing: 12) {
                                SettingItem(
                                    title: "Mode Aplikasi",
                                    subtitle: "Pilih tema gelap atau terang"
                                ) {
                                    Picker("Theme", selection: $appTheme) {
                                        Text("Gelap").tag("dark")
                                        Text("Terang").tag("light")
                                        Text("Sistem").tag("system")
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                SettingItem(
                                    title: "Intensitas Liquid Glass",
                                    subtitle: "Sesuaikan efek glass"
                                ) {
                                    Slider(value: $glassIntensity, in: 0...1)
                                        .tint(ColorTokens.neonGreen)
                                }
                                
                                SettingToggle(
                                    title: "Kurangi Transparansi",
                                    subtitle: "Gunakan warna solid untuk aksesibilitas",
                                    isOn: $reduceTransparency
                                )
                                
                                SettingToggle(
                                    title: "Haptic Feedback",
                                    subtitle: "Getaran saat interaksi",
                                    isOn: $enableHaptics
                                )
                            }
                        }
                        
                        // Language Section
                        SettingsSection(title: "Bahasa") {
                            Picker("Language", selection: $appLanguage) {
                                Text("Indonesia").tag("id")
                                Text("English").tag("en")
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(ColorTokens.cardBackground)
                            .cornerRadius(10)
                        }
                        
                        // Security Section
                        SettingsSection(title: "Keamanan") {
                            VStack(spacing: 12) {
                                SettingToggle(
                                    title: "Kunci Aplikasi",
                                    subtitle: "Gunakan Face ID / Touch ID",
                                    isOn: .constant(false)
                                )
                                
                                SettingItem(
                                    title: "Auto Lock",
                                    subtitle: "Kunci otomatis setelah 5 menit"
                                ) {
                                    Picker("AutoLock", selection: .constant("5")) {
                                        Text("1 menit").tag("1")
                                        Text("5 menit").tag("5")
                                        Text("10 menit").tag("10")
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                        
                        // Data Section
                        SettingsSection(title: "Data") {
                            VStack(spacing: 12) {
                                SettingButton(
                                    title: "Export CSV",
                                    icon: "arrow.down.doc.fill",
                                    action: {}
                                )
                                
                                SettingButton(
                                    title: "Import CSV",
                                    icon: "arrow.up.doc.fill",
                                    action: {}
                                )
                                
                                SettingButton(
                                    title: "Backup Cloud",
                                    icon: "icloud.and.arrow.up.fill",
                                    action: {}
                                )
                                
                                SettingButton(
                                    title: "Hapus Semua Data",
                                    icon: "trash.fill",
                                    action: {},
                                    isDanger: true
                                )
                            }
                        }
                        
                        // About Section
                        SettingsSection(title: "Tentang") {
                            VStack(spacing: 12) {
                                SettingInfo(title: "Versi Aplikasi", value: "1.0.0")
                                SettingInfo(title: "Build", value: "1")
                                
                                SettingButton(
                                    title: "Kebijakan Privasi",
                                    icon: "lock.fill",
                                    action: {}
                                )
                                
                                SettingButton(
                                    title: "Bantuan",
                                    icon: "questionmark.circle.fill",
                                    action: {}
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - Settings Components
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(TypographyTokens.labelMedium)
                .foregroundColor(ColorTokens.textSecondary)
            
            content
        }
    }
}

struct SettingItem<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(TypographyTokens.labelMedium)
                    .foregroundColor(ColorTokens.textPrimary)
                
                Text(subtitle)
                    .font(TypographyTokens.captionSmall)
                    .foregroundColor(ColorTokens.textSecondary)
            }
            
            Spacer()
            
            content
        }
        .padding(12)
        .background(ColorTokens.cardBackground)
        .cornerRadius(10)
    }
}

struct SettingToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(TypographyTokens.labelMedium)
                    .foregroundColor(ColorTokens.textPrimary)
                
                Text(subtitle)
                    .font(TypographyTokens.captionSmall)
                    .foregroundColor(ColorTokens.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(ColorTokens.neonGreen)
        }
        .padding(12)
        .background(ColorTokens.cardBackground)
        .cornerRadius(10)
    }
}

struct SettingButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var isDanger = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDanger ? ColorTokens.dangerRed : ColorTokens.neonGreen)
                
                Text(title)
                    .font(TypographyTokens.labelMedium)
                    .foregroundColor(isDanger ? ColorTokens.dangerRed : ColorTokens.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ColorTokens.textSecondary)
            }
            .padding(12)
            .background(ColorTokens.cardBackground)
            .cornerRadius(10)
        }
    }
}

struct SettingInfo: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(TypographyTokens.labelMedium)
                .foregroundColor(ColorTokens.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(TypographyTokens.labelMedium)
                .foregroundColor(ColorTokens.textSecondary)
        }
        .padding(12)
        .background(ColorTokens.cardBackground)
        .cornerRadius(10)
    }
}

#if DEBUG
struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileScreen()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
