# MoneyAssist Backend Documentation

## Overview
Backend API untuk aplikasi MoneyAssist iOS. Menggunakan REST API dengan authentication token-based (Sanctum).

## Base URL
```
https://monassist.vercel.app/api
```

## Authentication
Semua endpoint (kecuali `/register` dan `/login`) memerlukan Bearer token di header:
```
Authorization: Bearer {token}
```

---

## API Endpoints

### AUTH ENDPOINTS

#### 1. Register
```
POST /api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}

Response (201):
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

#### 2. Login
```
POST /api/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response (200):
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

#### 3. Get Current User
```
GET /api/me
Authorization: Bearer {token}

Response (200):
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

#### 4. Update Profile
```
PUT /api/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Jane Doe",
  "avatar_url": "https://...",
  "currency": "USD",
  "language": "en",
  "theme": "light",
  "notifications_enabled": false
}

Response (200):
{
  "success": true,
  "message": "Profile updated successfully",
  "data": { ... }
}
```

#### 5. Logout
```
POST /api/logout
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Logout successful"
}
```

---

### TRANSACTION ENDPOINTS

#### 1. Get All Transactions
```
GET /api/transactions
Authorization: Bearer {token}

Query Parameters:
- limit: int (default: 50)
- offset: int (default: 0)
- search: string (cari di title, merchant, note)
- category: int (filter by category_id)
- type: string (income/expense)
- start_date: string (YYYY-MM-DD)
- end_date: string (YYYY-MM-DD)
- min_amount: float
- max_amount: float
- payment_method: int
- is_favorite: boolean

Response (200):
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
    "count": 50,
    "per_page": 50,
    "current_page": 1,
    "total_pages": 2
  }
}
```

#### 2. Get Transaction Detail
```
GET /api/transactions/{id}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": { ... }
}
```

#### 3. Create Transaction
```
POST /api/transactions
Authorization: Bearer {token}
Content-Type: application/json

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

Response (201):
{
  "success": true,
  "message": "Transaction created successfully",
  "data": { ... }
}
```

#### 4. Update Transaction
```
PUT /api/transactions/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Makan Siang (Updated)",
  "amount": 55000,
  "is_favorite": true,
  "is_pinned": false
}

Response (200):
{
  "success": true,
  "message": "Transaction updated successfully",
  "data": { ... }
}
```

#### 5. Delete Transaction
```
DELETE /api/transactions/{id}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Transaction deleted successfully"
}
```

---

### CATEGORY ENDPOINTS

#### 1. Get All Categories
```
GET /api/categories
Authorization: Bearer {token}

Query Parameters:
- type: string (income/expense)

Response (200):
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

#### 2. Create Category
```
POST /api/categories
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Makanan",
  "icon": "fork.knife",
  "color": "#FF6B6B",
  "type": "expense"
}

Response (201):
{
  "success": true,
  "message": "Category created successfully",
  "data": { ... }
}
```

#### 3. Update Category
```
PUT /api/categories/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Makanan & Minuman",
  "color": "#FF8888"
}

Response (200):
{
  "success": true,
  "message": "Category updated successfully",
  "data": { ... }
}
```

#### 4. Delete Category
```
DELETE /api/categories/{id}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Category deleted successfully"
}
```

---

### BUDGET ENDPOINTS

#### 1. Get All Budgets
```
GET /api/budgets
Authorization: Bearer {token}

Query Parameters:
- month: int (1-12)
- year: int

Response (200):
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

#### 2. Create Budget
```
POST /api/budgets
Authorization: Bearer {token}
Content-Type: application/json

{
  "category_id": 1,
  "limit_amount": 500000,
  "month": 1,
  "year": 2024
}

Response (201):
{
  "success": true,
  "message": "Budget created successfully",
  "data": { ... }
}
```

#### 3. Update Budget
```
PUT /api/budgets/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "limit_amount": 600000
}

Response (200):
{
  "success": true,
  "message": "Budget updated successfully",
  "data": { ... }
}
```

#### 4. Delete Budget
```
DELETE /api/budgets/{id}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Budget deleted successfully"
}
```

---

### PAYMENT METHOD ENDPOINTS

#### 1. Get All Payment Methods
```
GET /api/payment-methods
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "Tunai",
      "type": "cash",
      "icon": "banknote.fill",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### 2. Create Payment Method
```
POST /api/payment-methods
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Kartu Kredit BCA",
  "type": "card",
  "icon": "creditcard.fill"
}

Response (201):
{
  "success": true,
  "message": "Payment method created successfully",
  "data": { ... }
}
```

#### 3. Update Payment Method
```
PUT /api/payment-methods/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Kartu Kredit BCA (Updated)"
}

Response (200):
{
  "success": true,
  "message": "Payment method updated successfully",
  "data": { ... }
}
```

#### 4. Delete Payment Method
```
DELETE /api/payment-methods/{id}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Payment method deleted successfully"
}
```

---

### SUMMARY ENDPOINTS

#### 1. Get Monthly Summary
```
GET /api/summary/monthly
Authorization: Bearer {token}

Query Parameters:
- month: int (1-12, default: current month)
- year: int (default: current year)

Response (200):
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

#### 2. Get Yearly Summary
```
GET /api/summary/yearly
Authorization: Bearer {token}

Query Parameters:
- year: int (default: current year)

Response (200):
{
  "success": true,
  "data": {
    "year": 2024,
    "total_income": 60000000,
    "total_expense": 30000000,
    "net_balance": 30000000,
    "monthly_breakdown": [
      {
        "month": 1,
        "total_income": 5000000,
        "total_expense": 2500000,
        "net_balance": 2500000
      }
    ]
  }
}
```

#### 3. Get Category Summary
```
GET /api/summary/category
Authorization: Bearer {token}

Query Parameters:
- type: string (income/expense)
- month: int
- year: int

Response (200):
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

#### 4. Get Trend Data
```
GET /api/summary/trend
Authorization: Bearer {token}

Query Parameters:
- days: int (7, 30, 365)

Response (200):
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

---

### RECEIPT ENDPOINTS

#### 1. Upload Receipt Image
```
POST /api/receipts/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- receipt: file (image/jpeg, max 5MB)

Response (201):
{
  "success": true,
  "message": "Receipt uploaded successfully",
  "data": {
    "id": 1,
    "url": "https://...",
    "ocr_text": "..."
  }
}
```

#### 2. OCR Receipt
```
POST /api/receipts/ocr
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- receipt: file (image/jpeg)

Response (200):
{
  "success": true,
  "data": {
    "merchant": "Restoran ABC",
    "date": "2024-01-15",
    "total": 50000,
    "items": [
      {
        "name": "Nasi Goreng",
        "price": 25000
      }
    ]
  }
}
```

#### 3. Get Receipt
```
GET /api/receipts/{id}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "id": 1,
    "transaction_id": 1,
    "image_url": "https://...",
    "ocr_text": "...",
    "extracted_json": { ... }
  }
}
```

---

### AI ENDPOINTS

#### 1. AI Chat
```
POST /api/ai/chat
Authorization: Bearer {token}
Content-Type: application/json

{
  "message": "Ringkas pengeluaran bulan ini"
}

Response (200):
{
  "success": true,
  "data": {
    "response": "Pengeluaran Anda bulan ini adalah Rp 2.500.000 dengan kategori terbesar adalah makanan (Rp 500.000)."
  }
}
```

#### 2. Get AI Insights
```
GET /api/ai/insights
Authorization: Bearer {token}

Query Parameters:
- limit: int (default: 10)
- type: string (spending_alert, saving_tip, category_insight, trend_analysis)

Response (200):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "type": "spending_alert",
      "title": "Pengeluaran Tinggi",
      "message": "Pengeluaran Anda bulan ini 20% lebih tinggi dari bulan lalu",
      "period": "monthly",
      "created_at": "2024-01-15T00:00:00Z"
    }
  ]
}
```

#### 3. Generate AI Insights
```
POST /api/ai/generate-insight
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Insights generated successfully"
}
```

---

### EXPORT/IMPORT ENDPOINTS

#### 1. Export CSV
```
GET /api/export/csv
Authorization: Bearer {token}

Query Parameters:
- start_date: string (YYYY-MM-DD)
- end_date: string (YYYY-MM-DD)

Response (200):
CSV file download
```

#### 2. Import CSV
```
POST /api/import/csv
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- file: file (text/csv)

Response (200):
{
  "success": true,
  "message": "CSV imported successfully",
  "data": {
    "imported_count": 50,
    "errors": []
  }
}
```

---

### SETTINGS ENDPOINTS

#### 1. Get Settings
```
GET /api/settings
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "theme": "dark",
    "language": "id",
    "notifications_enabled": true,
    "auto_lock_timeout": 300
  }
}
```

#### 2. Update Settings
```
PUT /api/settings
Authorization: Bearer {token}
Content-Type: application/json

{
  "theme": "light",
  "language": "en",
  "notifications_enabled": false
}

Response (200):
{
  "success": true,
  "message": "Settings updated successfully",
  "data": { ... }
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "email": ["Email is required"],
    "password": ["Password must be at least 8 characters"]
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized. Please login first."
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "You don't have permission to access this resource"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found"
}
```

### 422 Unprocessable Entity
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": { ... }
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## Rate Limiting
- 60 requests per minute per user
- 1000 requests per hour per user

---

## Pagination
Semua list endpoint mendukung pagination dengan query parameters:
- `limit`: jumlah item per halaman (default: 50, max: 100)
- `offset`: jumlah item yang di-skip (default: 0)

Response pagination:
```json
{
  "pagination": {
    "total": 100,
    "count": 50,
    "per_page": 50,
    "current_page": 1,
    "total_pages": 2
  }
}
```

---

## Date Format
Semua tanggal menggunakan format ISO 8601:
```
2024-01-15T12:30:00Z
```

---

## Currency
Default currency adalah IDR (Indonesian Rupiah). User dapat mengubah currency di profile.

---

## Notes
- Semua endpoint mengembalikan response dalam format JSON
- Semua request body harus dalam format JSON kecuali untuk multipart/form-data
- Token harus disimpan secara aman di Keychain (iOS)
- Implementasi refresh token untuk token expiration handling
