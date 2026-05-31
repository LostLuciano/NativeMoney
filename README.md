# MonassistNative — iOS 26 SwiftUI

Versi native 100% dari [Monassist](https://monassist.vercel.app) tanpa Flutter.  
Dibangun dengan **SwiftUI + iOS 26 Liquid Glass** di atas backend yang sama persis.

---

## Arsitektur

```
MonassistNative/
├── MonassistNativeApp.swift        @main entry point
├── Info.plist
├── Assets.xcassets/
│   └── AppIcon.appiconset/
│
├── Models/
│   ├── UserModel.swift
│   ├── TransactionModel.swift      (+ CategoryData inline)
│   └── CategoryModel.swift
│
├── Services/                       URLSession + async/await
│   ├── APIService.swift            Token auth, multipart, error decoding
│   ├── AuthService.swift           register / login / logout / profile
│   ├── TransactionService.swift    CRUD + statistics + user summary
│   ├── CategoryService.swift       CRUD categories
│   ├── AIService.swift             chat / recommendations / receipt scan
│   └── TelegramService.swift       pairing code / disconnect
│
└── UI/
    ├── RootViewSwitcher.swift      Onboarding → Auth → MainTab (spring transitions)
    ├── OnboardingView.swift        3-slide carousel, glass pagination
    ├── AuthView.swift              Login / Register, glass input fields
    ├── MainTabView.swift           .sidebarAdaptable + .tabBarMinimizeBehavior
    ├── HomeView.swift              Balance card, quick actions, budget bars, recent txs
    ├── TransactionHistoryView.swift Filter chips, grouped list, swipe-delete
    ├── AIChatView.swift            Bubbles, receipt scan (PhotosPicker), recommendations
    ├── SettingsView.swift          Profile edit, Telegram pairing, change password
    └── ViewModels/
        ├── AuthViewModel.swift
        ├── TransactionViewModel.swift  (offline mock fallback built-in)
        └── AIViewModel.swift           (smart mock replies + receipt scan sim)
```

---

## Backend

Base URL: `https://monassist.vercel.app/api`

| Endpoint | Keterangan |
|---|---|
| POST `/auth/login` | Login |
| POST `/auth/register` | Register |
| POST `/auth/logout` | Logout |
| GET `/auth/me` | Current user |
| PUT `/auth/profile` | Update profil |
| GET `/transactions` | List transaksi (filter, search, paging) |
| POST `/transactions` | Tambah transaksi |
| PUT `/transactions/:id` | Update transaksi |
| DELETE `/transactions/:id` | Hapus transaksi |
| GET `/transactions/statistics` | Statistik pemasukan/pengeluaran |
| GET `/categories` | List kategori |
| POST `/categories` | Tambah kategori |
| GET `/users/summary` | Ringkasan saldo |
| POST `/chat/message` | Chat AI |
| POST `/chat/receipt` | Scan struk (multipart) |
| GET `/recommendations` | Rekomendasi AI |
| POST `/auth/telegram-code` | Kode pairing Telegram |

---

## Setup Xcode

```bash
# 1. Clone atau buka folder ini
cd "D:/Project 100%/NativeMony/MonassistNative"

# 2. Generate ulang .xcodeproj kapanpun ada file baru
python Scripts/generate_xcodeproj.py

# 3. Buka di Xcode 26
open MonassistNative.xcodeproj
```

### Persyaratan
- **Xcode 26+** (iOS 26 SDK)
- **Swift 6**
- **Deployment target:** iOS 18+
- **Signing:** Set Team di Xcode → Target → Signing & Capabilities

---

## Desain — iOS 26 Liquid Glass

| Komponen | Teknik |
|---|---|
| Tombol & input | `.glassEffect(in: Capsule())` |
| Card / panel | `.glassEffect(.regular.tint(...), in: RoundedRectangle(...))` |
| Chat bubbles | `.glassEffect(.regular.tint(.blue.opacity(0.2)), in: RoundedRectangle(...))` |
| Tab bar | `.sidebarAdaptable` + otomatis Liquid Glass |
| Toolbar buttons | `GlassEffectContainer` + `.glassEffect()` per button |
| Scroll edge | Otomatis dari NavigationStack |
| Ambient glow | `Circle().fill(color.opacity(0.1)).blur(radius: 70)` |

---

## Assets (dari Monassist_ipa)

| File | Digunakan di |
|---|---|
| `icon.png` | AppIcon |
| `onboarding_wallet.png` | OnboardingView slide 1 |
| `onboarding_robot.png` | OnboardingView slide 2 |
| `onboarding_chart.png` | OnboardingView slide 3 |
| `splash_logo.png` | Launch screen |
| `card_3d.png` | (dekorasi HomeView, opsional) |
| `*.glb` | (siap untuk RealityKit/SceneKit jika diperlukan) |

---

## Offline Mode

`TransactionViewModel` dan `AIViewModel` memiliki **mock data bawaan** sehingga app tetap terlihat indah dan berfungsi interaktif saat backend tidak dapat dijangkau. Semua aksi UI (tambah/hapus transaksi, chat AI) tetap bekerja secara lokal.
