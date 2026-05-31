# MoneyAssist - Production Ready iOS App

![iOS](https://img.shields.io/badge/iOS-18%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-green)
![Liquid Glass](https://img.shields.io/badge/Liquid%20Glass-iOS%2026-purple)

**MoneyAssist** adalah aplikasi manajemen keuangan premium untuk iOS yang dibangun dengan SwiftUI native, Liquid Glass design system, dan arsitektur production-ready.

## 🎯 Fitur Utama

### 💰 Manajemen Transaksi
- ✅ Catat transaksi pemasukan & pengeluaran
- ✅ Scan struk dengan OCR
- ✅ Input transaksi via suara
- ✅ Import/Export CSV
- ✅ Kategorisasi otomatis
- ✅ Favorit & Pin transaksi
- ✅ Search & filter advanced

### 📊 Analisis & Insight
- ✅ Dashboard ringkasan bulanan
- ✅ Chart kategori (Donut Chart)
- ✅ Tren pengeluaran (Line Chart)
- ✅ AI Insights & rekomendasi
- ✅ Perbandingan periode
- ✅ Prediksi pengeluaran

### 💳 Budget Management
- ✅ Set budget per kategori
- ✅ Progress tracking real-time
- ✅ Alert mendekati limit
- ✅ Reminder bulanan
- ✅ Analisis budget vs actual

### 🤖 AI Assistant
- ✅ Chat dengan AI untuk analisis
- ✅ Pertanyaan natural language
- ✅ Rekomendasi penghematan
- ✅ Floating popup chat
- ✅ Minimize & drag functionality

### 🎨 Design Premium
- ✅ Liquid Glass effect (iOS 18+)
- ✅ Dark green premium theme
- ✅ Custom floating navbar
- ✅ Smooth spring animations
- ✅ Dark/Light mode support
- ✅ Accessibility compliant

### 🔒 Keamanan
- ✅ Face ID / Touch ID
- ✅ Keychain token storage
- ✅ Auto-lock timeout
- ✅ Encrypted data
- ✅ Secure API communication

---

## 📱 Platform Support

- ✅ iOS 18.0+
- ✅ iPhone (all sizes)
- ✅ iPad (landscape & portrait)
- ✅ Dark Mode
- ✅ Light Mode
- ✅ Dynamic Type
- ✅ Reduce Motion
- ✅ Reduce Transparency

---

## 🏗️ Arsitektur

### MVVM + Combine/Observation
```
┌─────────────────────────────────────┐
│      SwiftUI Views (UI Layer)       │
│  HomeScreen, TransactionScreen, ... │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   ViewModels (State Management)     │
│  HomeViewModel, TransactionViewModel │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Services (Business Logic)        │
│  APIService, AuthService, ...       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Models (Data Structures)       │
│  UserModel, TransactionModel, ...   │
└─────────────────────────────────────┘
```

### Folder Structure
```
MonassistNative/
├── Design/
│   ├── ColorTokens.swift           # Global color system
│   ├── TypographyTokens.swift      # Typography system
│   ├── LiquidGlassEffect.swift     # Liquid Glass components
│   ├── CustomNavbar.swift          # Custom floating navbar
│   └── ReusableComponents.swift    # Reusable UI components
│
├── Models/
│   ├── UserModel.swift             # User data model
│   ├── TransactionModel.swift      # Transaction data model
│   ├── CategoryModel.swift         # Category data model
│   ├── BudgetModel.swift           # Budget data model
│   ├── PaymentMethodModel.swift    # Payment method model
│   └── SummaryModel.swift          # Summary & insight models
│
├── Services/
│   ├── APIService.swift            # REST API client
│   ├── AuthService.swift           # Authentication
│   └── [Other Services]
│
├── UI/
│   ├── Screens/
│   │   ├── HomeScreen.swift        # Home dashboard
│   │   ├── TransactionScreen.swift # Transaction list & management
│   │   ├── AnalysisScreen.swift    # Analytics & insights
│   │   └── ProfileScreen.swift     # User profile & settings
│   │
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── TransactionViewModel.swift
│   │   ├── AnalysisViewModel.swift
│   │   └── ProfileViewModel.swift
│   │
│   └── MainTabView.swift           # Main tab navigation
│
├── MonassistNativeApp.swift        # App entry point
└── Info.plist                      # App configuration
```

---

## 🚀 Quick Start

### Prerequisites
- macOS 13.0+
- Xcode 15.0+
- iOS 18.0+ deployment target

### Installation
```bash
# Clone repository
git clone https://github.com/yourusername/monassist-native.git
cd MonassistNative

# Open in Xcode
open MonassistNative.xcodeproj

# Build & Run
Product → Run (⌘R)
```

### Configuration
1. Update API URL di `APIService.swift`
2. Configure app identifier di Xcode
3. Setup signing & capabilities
4. Verify Info.plist permissions

---

## 📚 Documentation

- **[Backend API Documentation](./BACKEND_DOCUMENTATION.md)** - Complete API reference
- **[Database Schema](./DATABASE_SCHEMA.md)** - Database structure & migrations
- **[Build Instructions](./BUILD_INSTRUCTIONS.md)** - Build, test, & deployment guide

---

## 🔌 API Integration

### Base URL
```
https://monassist.vercel.app/api
```

### Authentication
```swift
Authorization: Bearer {token}
```

### Key Endpoints
```
POST   /api/register              # Register user
POST   /api/login                 # Login
GET    /api/me                    # Get current user
PUT    /api/profile               # Update profile
POST   /api/logout                # Logout

GET    /api/transactions          # Get transactions
POST   /api/transactions          # Create transaction
PUT    /api/transactions/{id}     # Update transaction
DELETE /api/transactions/{id}     # Delete transaction

GET    /api/categories            # Get categories
POST   /api/categories            # Create category
PUT    /api/categories/{id}       # Update category
DELETE /api/categories/{id}       # Delete category

GET    /api/budgets               # Get budgets
POST   /api/budgets               # Create budget
PUT    /api/budgets/{id}          # Update budget
DELETE /api/budgets/{id}          # Delete budget

GET    /api/payment-methods       # Get payment methods
POST   /api/payment-methods       # Create payment method
PUT    /api/payment-methods/{id}  # Update payment method
DELETE /api/payment-methods/{id}  # Delete payment method

GET    /api/summary/monthly       # Monthly summary
GET    /api/summary/yearly        # Yearly summary
GET    /api/summary/category      # Category summary
GET    /api/summary/trend         # Trend data

POST   /api/ai/chat               # AI chat
GET    /api/ai/insights           # Get AI insights
POST   /api/ai/generate-insight   # Generate insights

GET    /api/export/csv            # Export CSV
POST   /api/import/csv            # Import CSV

GET    /api/settings              # Get settings
PUT    /api/settings              # Update settings
```

Lihat [Backend Documentation](./BACKEND_DOCUMENTATION.md) untuk detail lengkap.

---

## 🎨 Design System

### Color Tokens
```swift
ColorTokens.primaryGreen      // #267B5A - Primary brand color
ColorTokens.neonGreen        // #33CC80 - Accent color
ColorTokens.darkBackground   // #141416 - App background
ColorTokens.cardBackground   // #1F1F26 - Card background
ColorTokens.glassStroke      // #4D4D59 - Glass border
ColorTokens.textPrimary      // #F2F2F7 - Primary text
ColorTokens.textSecondary    // #999AAA - Secondary text
ColorTokens.dangerRed        // #E63333 - Error/Danger
ColorTokens.warningYellow    // #FFBF33 - Warning
ColorTokens.successGreen     // #33CC66 - Success
```

### Typography
```swift
TypographyTokens.displayLarge    // 34pt Bold
TypographyTokens.displayMedium   // 28pt Bold
TypographyTokens.headlineLarge   // 22pt Semibold
TypographyTokens.headlineMedium  // 20pt Semibold
TypographyTokens.titleLarge      // 16pt Semibold
TypographyTokens.bodyLarge       // 16pt Regular
TypographyTokens.bodyMedium      // 14pt Regular
TypographyTokens.labelLarge      // 14pt Medium
TypographyTokens.monospaceMedium // 16pt Monospace
```

### Reusable Components
- `LiquidGlassCard` - Glass effect card with inner highlight
- `LiquidGlassButton` - Interactive button with spring animation
- `LiquidGlassNavbar` - Custom floating navbar
- `LiquidGlassSheet` - Modal sheet with glass effect
- `FloatingAIButton` - AI chat floating button
- `TransactionCard` - Transaction list item
- `BudgetCard` - Budget progress card
- `InsightCard` - AI insight card
- `EmptyStateView` - Empty state placeholder
- `LoadingSkeletonView` - Loading skeleton
- `ErrorStateView` - Error state placeholder

---

## 🔐 Permissions

Aplikasi meminta izin untuk:
- 📷 **Camera** - Scan struk transaksi
- 🖼️ **Photo Library** - Upload foto struk dari galeri
- 🎤 **Microphone** - Input transaksi via suara
- 🗣️ **Speech Recognition** - Konversi suara ke teks
- 👤 **Face ID** - Keamanan aplikasi
- 📍 **Location** - Tag lokasi transaksi (opsional)

**Penting:** Semua izin diminta hanya saat fitur terkait digunakan, bukan saat app launch.

---

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme MonassistNative
```

### UI Tests
```bash
xcodebuild test -scheme MonassistNative -only-testing:MonassistNativeUITests
```

### Code Coverage
```bash
xcodebuild test -scheme MonassistNative -enableCodeCoverage YES
```

---

## 📦 Build & Release

### Development Build
```bash
Product → Run (⌘R)
```

### Release Build
```bash
Product → Archive
```

### Export IPA
```bash
xcodebuild -exportArchive \
  -archivePath build/MonassistNative.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/
```

Lihat [Build Instructions](./BUILD_INSTRUCTIONS.md) untuk detail lengkap.

---

## ♿ Accessibility

- ✅ VoiceOver support
- ✅ Dynamic Type scaling
- ✅ High contrast mode
- ✅ Reduce transparency fallback
- ✅ Haptic feedback
- ✅ Keyboard navigation
- ✅ Color contrast compliance

---

## 🌍 Localization

Supported languages:
- 🇮🇩 Indonesian (id)
- 🇬🇧 English (en)

---

## 📊 Performance

- ⚡ Lazy loading transactions
- ⚡ Efficient filtering & sorting
- ⚡ Optimized images
- ⚡ Minimal memory footprint
- ⚡ Smooth 60 FPS animations
- ⚡ Async/await for non-blocking operations

---

## 🔄 State Management

### Observation Framework
```swift
@StateObject private var viewModel = HomeViewModel()
@Published var transactions: [TransactionModel] = []
@Published var isLoading = false
```

### Combine
```swift
@Published var errorMessage: String?
@Published var selectedTab = 0
```

---

## 🐛 Troubleshooting

### Build Errors
```bash
# Clean build
xcodebuild clean -scheme MonassistNative

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Rebuild
xcodebuild build -scheme MonassistNative
```

### Runtime Issues
- Check API URL configuration
- Verify network connectivity
- Check Keychain permissions
- Review Info.plist permissions

---

## 📄 License

MIT License - see LICENSE file for details

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

---

## 📞 Support

- 📧 Email: support@monassist.app
- 🐛 Issues: GitHub Issues
- 💬 Discussions: GitHub Discussions

---

## 📈 Roadmap

### v1.1.0
- [ ] Recurring transactions
- [ ] Multi-currency support
- [ ] Advanced charts
- [ ] Export to PDF

### v1.2.0
- [ ] Cloud sync
- [ ] Shared budgets
- [ ] Investment tracking
- [ ] Tax reports

### v2.0.0
- [ ] macOS app
- [ ] watchOS app
- [ ] Web dashboard
- [ ] API for third-party apps

---

**Made with ❤️ for better financial management**
