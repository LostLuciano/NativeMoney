import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let tintColor: Color
}

public struct OnboardingView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentPage = 0
    
    private let slides = [
        OnboardingItem(
            title: "Catat Keuangan Otomatis",
            description: "Kelola seluruh pengeluaran dan pemasukan Anda secara real-time dengan praktis tanpa ribet.",
            imageName: "onboarding_wallet",
            tintColor: Color.blue
        ),
        OnboardingItem(
            title: "Analisis AI Finansial",
            description: "Dapatkan saran finansial cerdas dan tips hemat otomatis dari Monassist AI Asisten Anda.",
            imageName: "onboarding_robot",
            tintColor: Color.purple
        ),
        OnboardingItem(
            title: "Grafik & Statistik Menarik",
            description: "Lihat visualisasi pengeluaran Anda per kategori dengan ringkasan budget bulanan yang interaktif.",
            imageName: "onboarding_chart",
            tintColor: Color.green
        )
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Elegant Dark Backdrop with Glowing Radial Halos
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            // Background Ambient Glow
            GeometryReader { geo in
                Circle()
                    .fill(slides[currentPage].tintColor.opacity(0.12))
                    .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                    .blur(radius: 80)
                    .offset(x: -geo.size.width * 0.1, y: -geo.size.height * 0.25)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: currentPage)
            }
            
            VStack(spacing: 0) {
                // Header Logo
                HStack(spacing: 8) {
                    Image(systemName: "banknote.fill")
                        .font(.title2)
                        .foregroundStyle(LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("MONASSIST")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .tracking(1.5)
                        .foregroundStyle(.white)
                }
                .padding(.top, 20)
                
                // Sliders Pager
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { idx in
                        let slide = slides[idx]
                        VStack(spacing: 32) {
                            Spacer()
                            
                            // 3D Visual Asset Illustration
                            // Falls back to system glyph if image asset is not loaded in Xcode Catalog
                            Image(slide.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 280)
                                .shadow(color: slide.tintColor.opacity(0.3), radius: 25, x: 0, y: 15)
                                .overlay {
                                    if Bundle.main.path(forResource: slide.imageName, ofType: "png") == nil {
                                        // Dynamic Fallback visual if images are not compiled in app bundle yet
                                        VStack {
                                            Image(systemName: idx == 0 ? "wallet.pass.fill" : idx == 1 ? "cpu.fill" : "chart.pie.fill")
                                                .font(.system(size: 100))
                                                .foregroundStyle(slide.tintColor)
                                                .padding()
                                        }
                                    }
                                }
                            
                            VStack(spacing: 16) {
                                Text(slide.title)
                                    .font(.system(.title, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                
                                Text(slide.description)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Section: Navigation & Action
                VStack(spacing: 24) {
                    // Custom Glassy Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { idx in
                            Circle()
                                .fill(idx == currentPage ? slides[currentPage].tintColor : Color.white.opacity(0.2))
                                .frame(width: idx == currentPage ? 12 : 8, height: idx == currentPage ? 12 : 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .glassEffect() // Glassy Pill indicator wrapper
                    
                    // Main Action Button
                    Button(action: {
                        if currentPage < slides.count - 1 {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                authVM.completeOnboarding()
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage == slides.count - 1 ? "Mulai Sekarang" : "Lanjutkan")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "chevron.right")
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                    }
                    .tint(slides[currentPage].tintColor)
                    .glassEffect() // Apply iOS 26 glass effect to the primary button capsule!
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
