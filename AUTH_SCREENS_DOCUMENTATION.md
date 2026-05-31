# Authentication Screens Documentation

## Overview
Dokumentasi untuk Login dan Register screens yang telah diimplementasikan dengan design modern (Liquid Glass effect).

## Screens

### 1. Login Screen

#### File Location
`MonassistNative/UI/Screens/LoginScreen.swift`

#### Features
- Email input field dengan validasi
- Password input field dengan toggle show/hide
- Remember me checkbox
- Forgot password link
- Login button dengan loading state
- Link ke Register screen
- Error handling dengan alert

#### Design Elements
- Dark gradient background (Liquid Glass style)
- Green accent color (#66CC99 / RGB: 0.4, 0.8, 0.6)
- Smooth animations dan transitions
- Responsive layout

#### Validation
- Email tidak boleh kosong
- Password tidak boleh kosong
- Email format validation (via API)
- Password minimum 8 karakter (via API)

#### API Integration
- Endpoint: `POST /api/auth/login`
- Menyimpan token ke UserDefaults
- Automatic redirect ke MainTabView setelah login sukses

#### Usage
```swift
NavigationStack {
    LoginScreen()
}
```

---

### 2. Register Screen

#### File Location
`MonassistNative/UI/Screens/RegisterScreen.swift`

#### Features
- Name input field
- Email input field dengan validasi
- Password input field dengan toggle show/hide
- Confirm password field dengan toggle show/hide
- Terms & conditions checkbox (required)
- Register button dengan loading state
- Link ke Login screen
- Error handling dengan alert

#### Design Elements
- Dark gradient background (Liquid Glass style)
- Green accent color (#66CC99)
- Smooth animations dan transitions
- ScrollView untuk mobile responsiveness
- Disabled button state saat terms tidak disetujui

#### Validation
- Nama tidak boleh kosong
- Email tidak boleh kosong
- Password minimal 8 karakter
- Password dan confirm password harus sama
- Terms & conditions harus disetujui
- Email format validation (via API)

#### API Integration
- Endpoint: `POST /api/auth/register`
- Menyimpan token ke UserDefaults
- Automatic redirect ke MainTabView setelah register sukses

#### Usage
```swift
NavigationStack {
    RegisterScreen()
}
```

---

## Design System

### Colors
```swift
// Background
Primary: Color(red: 0.05, green: 0.05, blue: 0.15)
Secondary: Color(red: 0.08, green: 0.08, blue: 0.2)

// Input Fields
Background: Color(red: 0.12, green: 0.12, blue: 0.22)
Border: Color(red: 0.2, green: 0.2, blue: 0.3)

// Accent
Primary: Color(red: 0.4, green: 0.8, blue: 0.6) // Green
Secondary: Color(red: 0.3, green: 0.7, blue: 0.5) // Darker Green

// Text
Primary: .white
Secondary: .gray
```

### Typography
```swift
// Headers
Font: .system(size: 32, weight: .bold)

// Subheaders
Font: .system(size: 16, weight: .regular)

// Labels
Font: .system(size: 14, weight: .semibold)

// Body
Font: .system(size: 14, weight: .regular)

// Small
Font: .system(size: 12, weight: .regular)
```

### Components

#### Input Field
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Label")
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.white)
    
    HStack {
        Image(systemName: "icon.name")
            .foregroundColor(.gray)
        
        TextField("Placeholder", text: $state)
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
```

#### Button
```swift
Button(action: {}) {
    Text("Button Text")
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(.white)
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
```

---

## Integration with MainTabView

### Login Flow
1. User opens app
2. MainTabView checks `APIService.shared.isLoggedIn`
3. If not logged in, show LoginScreen
4. User enters credentials dan tap "Masuk"
5. LoginScreen calls `AuthService.shared.login()`
6. Token disimpan ke UserDefaults
7. MainTabView automatically shows MainTabView content

### Register Flow
1. User di LoginScreen tap "Daftar sekarang"
2. Navigate ke RegisterScreen
3. User mengisi form dan tap "Daftar"
4. RegisterScreen calls `AuthService.shared.register()`
5. Token disimpan ke UserDefaults
6. RegisterScreen dismiss dan kembali ke LoginScreen
7. User dapat langsung login atau MainTabView auto-redirect

---

## Error Handling

### Login Errors
```swift
// Empty fields
"Email dan password harus diisi"

// API errors
- 401 Unauthorized: "Email atau password salah"
- 422 Unprocessable Entity: "Validasi gagal"
- 500 Server Error: "Terjadi kesalahan sistem"
- Network Error: "Kesalahan jaringan: [error message]"
```

### Register Errors
```swift
// Validation errors
"Nama harus diisi"
"Email harus diisi"
"Password minimal 8 karakter"
"Password tidak cocok"
"Anda harus menyetujui syarat & ketentuan"

// API errors
- 422 Unprocessable Entity: "Email sudah terdaftar"
- 500 Server Error: "Terjadi kesalahan sistem"
- Network Error: "Kesalahan jaringan: [error message]"
```

---

## State Management

### AuthViewModel
```swift
@StateObject private var viewModel = AuthViewModel()
```

### Local State
```swift
@State private var email = ""
@State private var password = ""
@State private var showPassword = false
@State private var isLoading = false
@State private var errorMessage = ""
@State private var showError = false
```

---

## Security Considerations

1. **Token Storage**
   - Token disimpan di UserDefaults (should use Keychain in production)
   - Token dikirim di Authorization header untuk setiap request

2. **Password Security**
   - Password tidak pernah di-log
   - Password field menggunakan SecureField
   - Toggle show/hide password tersedia

3. **HTTPS Only**
   - Semua API calls menggunakan HTTPS
   - Base URL: `https://monassist.vercel.app/api`

4. **Token Expiration**
   - API returns 401 jika token expired
   - APIService automatically clears token
   - User akan di-redirect ke LoginScreen

---

## Testing

### Manual Testing Checklist

#### Login Screen
- [ ] Email field accepts input
- [ ] Password field accepts input
- [ ] Show/hide password toggle works
- [ ] Remember me checkbox works
- [ ] Forgot password link navigates correctly
- [ ] Login button disabled saat fields kosong
- [ ] Loading state shows saat login
- [ ] Error alert shows untuk invalid credentials
- [ ] Successful login redirects ke MainTabView
- [ ] Register link navigates ke RegisterScreen

#### Register Screen
- [ ] Name field accepts input
- [ ] Email field accepts input
- [ ] Password field accepts input
- [ ] Confirm password field accepts input
- [ ] Show/hide password toggles work
- [ ] Terms checkbox required untuk enable button
- [ ] Register button disabled saat terms unchecked
- [ ] Loading state shows saat register
- [ ] Validation errors show correctly
- [ ] Successful register redirects ke MainTabView
- [ ] Login link navigates ke LoginScreen

---

## Future Enhancements

1. **Social Login**
   - Google Sign-In
   - Apple Sign-In
   - Facebook Login

2. **Two-Factor Authentication**
   - SMS OTP
   - Email OTP
   - Authenticator app

3. **Biometric Authentication**
   - Face ID
   - Touch ID

4. **Password Reset**
   - Email verification
   - Reset link
   - New password confirmation

5. **Session Management**
   - Remember device
   - Session timeout
   - Logout all devices

---

## API Endpoints Reference

### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "success": true,
  "message": "Login successful",
  "data": { ... },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Register
```
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}

Response (201):
{
  "success": true,
  "message": "User registered successfully",
  "data": { ... },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

---

## Troubleshooting

### Login not working
1. Check internet connection
2. Verify email and password are correct
3. Check if account exists (try register)
4. Check API server status

### Register not working
1. Check internet connection
2. Verify all fields are filled correctly
3. Check if email already registered
4. Check if password meets requirements

### Token not persisting
1. Check UserDefaults is working
2. Verify token is being set correctly
3. Check if app is being terminated
4. Consider using Keychain for production

### Redirect not working
1. Check APIService.isLoggedIn property
2. Verify MainTabView is checking login status
3. Check if token is being cleared on logout
4. Verify NavigationStack is set up correctly
