# MonassistNative - API Integration Guide

## 🔌 Base URL
```
https://monassist.vercel.app/api
```

## 📋 API Endpoints Overview

Semua endpoints yang digunakan dalam aplikasi MonassistNative sudah terintegrasi penuh dengan Service Layer.

---

## 🔐 Authentication Endpoints

### 1. Register User
**Endpoint:** `POST /api/auth/register`

**Service:** `AuthService.register()`

```swift
let response = try await AuthService.shared.register(
    name: "John Doe",
    email: "john@example.com",
    password: "password123"
)
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "avatar_url": null,
    "currency": "IDR",
    "language": "id",
    "theme": "dark",
    "notifications_enabled": true,
    "created_at": "2024-01-01T00:00:00Z"
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Implementation:** `UI/Screens/RegisterScreen.swift`

---

### 2. Login User
**Endpoint:** `POST /api/auth/login`

**Service:** `AuthService.login()`

```swift
let response = try await AuthService.shared.login(
    email: "john@example.com",
    password: "password123"
)
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    ...
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Implementation:** `UI/Screens/LoginScreen.swift`

---

### 3. Logout User
**Endpoint:** `POST /api/auth/logout`

**Service:** `AuthService.logout()`

```swift
let success = try await AuthService.shared.logout()
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

**Implementation:** `UI/Screens/ProfileScreen.swift`

---

### 4. Get Current User
**Endpoint:** `GET /api/auth/me`

**Service:** `AuthService.getCurrentUser()`

```swift
let user = try await AuthService.shared.getCurrentUser()
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "avatar_url": "https://...",
    "currency": "IDR",
    "language": "id",
    "theme": "dark",
    "notifications_enabled": true,
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

**Implementation:** `UI/ViewModels/HomeViewModel.swift`, `UI/ViewModels/ProfileViewModel.swift`

---

### 5. Update Profile
**Endpoint:** `PUT /api/auth/profile`

**Service:** `AuthService.updateProfile()`

```swift
let response = try await AuthService.shared.updateProfile(
    name: "Jane Doe",
    currency: "USD",
    language: "en",
    theme: "light"
)
```

**Request Body:**
```json
{
  "name": "Jane Doe",
  "phone": "+62812345678",
  "currency": "USD",
  "language": "en",
  "theme": "light",
  "bio": "Finance enthusiast",
  "notifications_enabled": true
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": { ... }
}
```

**Implementation:** `UI/Screens/ProfileScreen.swift`

---

## 💳 Transaction Endpoints

### 1. Get All Transactions
**Endpoint:** `GET /api/transactions`

**Service:** `TransactionService.getTransactions()`

```swift
let transactions = try await TransactionService.shared.getTransactions(
    categoryId: 1,
    type: "expense",
    startDate: Date(),
    endDate: Date(),
    search: "makan",
    page: 1,
    limit: 20
)
```

**Query Parameters:**
- `category_id` (optional) - Filter by category
- `type` (optional) - "income" or "expense"
- `start_date` (optional) - YYYY-MM-DD format
- `end_date` (optional) - YYYY-MM-DD format
- `search` (optional) - Search in title, merchant, note
- `page` (optional) - Page number (default: 1)
- `limit` (optional) - Items per page (default: 20)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "type": "expense",
      "title": "Makan Siang",
      "merchant": "Restoran ABC",
      "amount": 50000,
      "category_id": 1,
      "payment_method_id": 1,
      "note": "Makan dengan teman",
      "transaction_date": "2024-01-15T12:30:00Z",
      "receipt_image_url": "https://...",
      "location_name": "Jakarta",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "is_favorite": false,
      "is_pinned": false,
      "created_at": "2024-01-15T12:30:00Z",
      "updated_at": "2024-01-15T12:30:00Z",
      "category": { ... },
      "payment_method": { ... }
    }
  ],
  "pagination": {
    "total": 100,
    "count": 20,
    "per_page": 20,
    "current_page": 1,
    "total_pages": 5
  }
}
```

**Implementation:** `UI/ViewModels/TransactionViewModel.swift`, `UI/Screens/TransactionScreen.swift`

---

### 2. Create Transaction
**Endpoint:** `POST /api/transactions`

**Service:** `TransactionService.addTransaction()`

```swift
let response = try await TransactionService.shared.addTransaction(
    categoryId: 1,
    type: "expense",
    amount: 50000,
    description: "Makan Siang",
    date: Date(),
    receiptUrl: nil,
    tags: ["food"],
    notes: "Makan dengan teman"
)
```

**Request Body:**
```json
{
  "type": "expense",
  "title": "Makan Siang",
  "merchant": "Restoran ABC",
  "amount": 50000,
  "category_id": 1,
  "payment_method_id": 1,
  "note": "Makan dengan teman",
  "transaction_date": "2024-01-15T12:30:00Z",
  "location_name": "Jakarta"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Transaction created successfully",
  "data": { ... }
}
```

**Implementation:** `UI/Screens/AddTransactionScreen.swift`, `UI/ViewModels/TransactionViewModel.swift`

---

### 3. Update Transaction
**Endpoint:** `PUT /api/transactions/:id`

**Service:** `TransactionService.updateTransaction()`

```swift
let response = try await TransactionService.shared.updateTransaction(
    transactionId: 1,
    title: "Makan Siang (Updated)",
    amount: 55000
)
```

**Request Body:**
```json
{
  "title": "Makan Siang (Updated)",
  "amount": 55000,
  "is_favorite": true
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Transaction updated successfully",
  "data": { ... }
}
```

---

### 4. Delete Transaction
**Endpoint:** `DELETE /api/transactions/:id`

**Service:** `TransactionService.deleteTransaction()`

```swift
let success = try await TransactionService.shared.deleteTransaction(1)
```

**Response (200):**
```json
{
  "success": true,
  "message": "Transaction deleted successfully"
}
```

**Implementation:** `UI/Screens/TransactionDetailScreen.swift`

---

### 5. Get Transaction Statistics
**Endpoint:** `GET /api/transactions/statistics`

**Service:** `TransactionService.getStatistics()`

```swift
let stats = try await TransactionService.shared.getStatistics(
    startDate: Date(),
    endDate: Date()
)
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_income": 5000000,
    "total_expense": 2500000,
    "net_balance": 2500000,
    "transaction_count": 50
  }
}
```

---

## 📂 Category Endpoints

### 1. Get All Categories
**Endpoint:** `GET /api/categories`

**Service:** `CategoryService.getCategories()`

```swift
let categories = try await CategoryService.shared.getCategories()
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "Makanan",
      "icon": "fork.knife",
      "color": "#FF6B6B",
      "type": "expense",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

**Implementation:** `UI/ViewModels/TransactionViewModel.swift`, `UI/ViewModels/AnalysisViewModel.swift`

---

### 2. Create Category
**Endpoint:** `POST /api/categories`

**Service:** `CategoryService.addCategory()`

```swift
let response = try await CategoryService.shared.addCategory(
    name: "Makanan",
    type: "expense",
    icon: "fork.knife",
    color: "#FF6B6B"
)
```

**Request Body:**
```json
{
  "name": "Makanan",
  "icon": "fork.knife",
  "color": "#FF6B6B",
  "type": "expense"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Category created successfully",
  "data": { ... }
}
```

---

### 3. Update Category
**Endpoint:** `PUT /api/categories/:id`

**Service:** `CategoryService.updateCategory()`

```swift
let response = try await CategoryService.shared.updateCategory(
    categoryId: 1,
    name: "Makanan & Minuman",
    color: "#FF8888"
)
```

**Request Body:**
```json
{
  "name": "Makanan & Minuman",
  "color": "#FF8888"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Category updated successfully",
  "data": { ... }
}
```

---

### 4. Delete Category
**Endpoint:** `DELETE /api/categories/:id`

**Service:** `CategoryService.deleteCategory()`

```swift
let success = try await CategoryService.shared.deleteCategory(1)
```

**Response (200):**
```json
{
  "success": true,
  "message": "Category deleted successfully"
}
```

---

## 💰 Budget Endpoints

### 1. Get All Budgets
**Endpoint:** `GET /api/budgets`

**Service:** `BudgetViewModel.loadBudgets()`

```swift
let response = try await apiService.get(endpoint: "/budgets")
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "category_id": 1,
      "limit_amount": 500000,
      "month": 1,
      "year": 2024,
      "spent": 250000,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z",
      "category": { ... }
    }
  ]
}
```

**Implementation:** `UI/ViewModels/BudgetViewModel.swift`, `UI/Screens/BudgetScreen.swift`

---

### 2. Create Budget
**Endpoint:** `POST /api/budgets`

**Service:** `BudgetViewModel.createBudget()`

```swift
let response = try await apiService.post(
    endpoint: "/budgets",
    body: [
        "category_id": 1,
        "limit_amount": 500000,
        "month": "2024-01"
    ]
)
```

**Request Body:**
```json
{
  "category_id": 1,
  "limit_amount": 500000,
  "month": 1,
  "year": 2024
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Budget created successfully",
  "data": { ... }
}
```

---

### 3. Update Budget
**Endpoint:** `PUT /api/budgets/:id`

**Request Body:**
```json
{
  "limit_amount": 600000
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Budget updated successfully",
  "data": { ... }
}
```

---

### 4. Delete Budget
**Endpoint:** `DELETE /api/budgets/:id`

**Service:** `BudgetViewModel.deleteBudget()`

**Response (200):**
```json
{
  "success": true,
  "message": "Budget deleted successfully"
}
```

**Implementation:** `UI/Screens/BudgetScreen.swift`

---

## 👤 User Endpoints

### 1. Get User Summary
**Endpoint:** `GET /api/users/summary`

**Service:** `TransactionService.getUserSummary()`

```swift
let summary = try await TransactionService.shared.getUserSummary()
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_income": 5000000,
    "total_expense": 2500000,
    "net_balance": 2500000,
    "transaction_count": 50,
    "category_count": 10,
    "budget_count": 5
  }
}
```

**Implementation:** `UI/ViewModels/HomeViewModel.swift`, `UI/ViewModels/AnalysisViewModel.swift`

---

## 📊 Summary Endpoints

### 1. Get Monthly Summary
**Endpoint:** `GET /api/summary/monthly`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "month": 1,
    "year": 2024,
    "total_income": 5000000,
    "total_expense": 2500000,
    "net_balance": 2500000
  }
}
```

**Implementation:** `UI/ViewModels/HomeViewModel.swift`, `UI/ViewModels/TransactionViewModel.swift`

---

### 2. Get Category Summary
**Endpoint:** `GET /api/summary/category`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "category_id": 1,
      "category_name": "Makanan",
      "category_icon": "fork.knife",
      "category_color": "#FF6B6B",
      "total_amount": 500000,
      "percentage": 20.0,
      "transaction_count": 10
    }
  ]
}
```

**Implementation:** `UI/ViewModels/AnalysisViewModel.swift`, `UI/Screens/AnalysisScreen.swift`

---

### 3. Get Trend Data
**Endpoint:** `GET /api/summary/trend`

**Query Parameters:**
- `days` - 7, 30, or 365

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "date": "2024-01-15",
      "income": 1000000,
      "expense": 500000,
      "balance": 500000
    }
  ]
}
```

**Implementation:** `UI/ViewModels/AnalysisViewModel.swift`

---

## 🤖 AI Endpoints

### 1. AI Chat
**Endpoint:** `POST /api/ai/chat`

**Service:** `AIService.sendChatMessage()`

```swift
let response = try await AIService.shared.sendChatMessage(
    "Ringkas pengeluaran bulan ini"
)
```

**Request Body:**
```json
{
  "message": "Ringkas pengeluaran bulan ini",
  "type": "general"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "response": "Pengeluaran Anda bulan ini adalah Rp 2.500.000..."
  }
}
```

**Implementation:** `UI/Screens/HomeScreen.swift`, `Design/CustomNavbar.swift` (AIChatPopup)

---

### 2. Generate Transaction (Buatin)
**Endpoint:** `POST /api/buatin`

**Service:** `AIService.generateTransaction()`

```swift
let response = try await AIService.shared.generateTransaction(
    prompt: "Beli makan siang di restoran ABC sebesar 50 ribu"
)
```

**Request Body:**
```json
{
  "prompt": "Beli makan siang di restoran ABC sebesar 50 ribu"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "type": "expense",
    "title": "Makan Siang",
    "merchant": "Restoran ABC",
    "amount": 50000,
    "category": "Makanan & Minuman",
    "category_id": 1,
    "payment_method": "Tunai",
    "payment_method_id": 1,
    "date": "2024-01-15T12:30:00Z",
    "confidence": 0.95
  }
}
```

**Implementation:** `UI/Screens/BuatinScreen.swift`, `UI/ViewModels/AIViewModel.swift`

---

## 🔑 Authentication

Semua endpoints (kecuali `/auth/register` dan `/auth/login`) memerlukan Bearer token di header:

```swift
Authorization: Bearer {token}
```

Token disimpan di `UserDefaults` dengan key `"auth_token"` dan dikelola oleh `APIService`.

---

## ⚠️ Error Handling

### Error Responses

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "email": ["Email is required"]
  }
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Unauthorized. Please login first."
}
```

**422 Unprocessable Entity:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": { ... }
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## 📁 Service Layer Structure

```
Services/
├── APIService.swift          # Base HTTP client
├── AuthService.swift         # Authentication
├── TransactionService.swift  # Transactions
├── CategoryService.swift     # Categories
├── AIService.swift          # AI features
└── TelegramService.swift    # Telegram integration
```

---

## 🔄 Request/Response Flow

```
UI Screen
    ↓
ViewModel (async/await)
    ↓
Service Layer (AuthService, TransactionService, etc.)
    ↓
APIService (HTTP client)
    ↓
Backend API (https://monassist.vercel.app/api)
    ↓
Response → Decode → ViewModel → UI Update
```

---

## 📝 Implementation Checklist

- ✅ Authentication (Register, Login, Logout, Get User, Update Profile)
- ✅ Transactions (Get, Create, Update, Delete, Statistics)
- ✅ Categories (Get, Create, Update, Delete)
- ✅ Budgets (Get, Create, Update, Delete)
- ✅ Summary (Monthly, Category, Trend)
- ✅ AI Features (Chat, Generate Transaction)
- ✅ Error Handling
- ✅ Token Management
- ✅ Async/Await Pattern
- ✅ Loading States
- ✅ Empty States

---

## 🚀 Ready for Deployment

Semua API endpoints sudah terintegrasi penuh dengan aplikasi. Siap untuk:
1. Push ke GitHub
2. Build untuk TestFlight
3. Deploy ke App Store

---

## 📞 Support

Untuk pertanyaan atau masalah API integration, silakan hubungi tim backend di:
- Email: backend@monassist.com
- API Documentation: https://monassist.vercel.app/api/docs
