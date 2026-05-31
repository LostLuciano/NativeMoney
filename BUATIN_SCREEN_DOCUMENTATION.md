# Buatin Screen Documentation

## Overview
Dokumentasi untuk Buatin Screen - fitur AI untuk generate transaksi otomatis berdasarkan deskripsi natural language.

## File Location
`MonassistNative/UI/Screens/BuatinScreen.swift`

## Features

### Main Screen (BuatinScreen)
1. **Input Section**
   - TextEditor untuk deskripsi transaksi
   - Placeholder text dengan contoh
   - Helper text dengan format yang disarankan

2. **Quick Templates**
   - Makan (🍔)
   - Transportasi (🚕)
   - Belanja (🛍️)
   - Pemasukan (💰)
   - One-tap untuk mengisi prompt

3. **Info Box**
   - Menjelaskan fungsi AI
   - Memberikan ekspektasi kepada user

4. **Generate Button**
   - Disabled saat prompt kosong
   - Loading state saat processing
   - Sparkles icon untuk visual appeal

### Result Sheet (BuatinResultSheet)
1. **Transaction Details**
   - Title dan merchant
   - Amount dengan format currency
   - Transaction type (expense/income)

2. **Details Grid**
   - Kategori
   - Metode pembayaran
   - Tanggal
   - Catatan (jika ada)

3. **Action Buttons**
   - Simpan Transaksi (primary)
   - Batal (secondary)

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

// Info Box
Background: Color(red: 0.1, green: 0.25, blue: 0.2)

// Text
Primary: .white
Secondary: .gray
```

### Typography
```swift
// Headers
Font: .system(size: 28, weight: .bold)

// Subheaders
Font: .system(size: 14, weight: .regular)

// Labels
Font: .system(size: 14, weight: .semibold)

// Body
Font: .system(size: 14, weight: .regular)

// Small
Font: .system(size: 12, weight: .regular)
```

---

## Components

### QuickTemplateButton
```swift
struct QuickTemplateButton: View {
    let icon: String
    let title: String
    let action: () -> Void
}
```

**Usage:**
```swift
QuickTemplateButton(
    icon: "🍔",
    title: "Makan",
    action: { prompt = "Makan siang di restoran" }
)
```

### DetailRow
```swift
struct DetailRow: View {
    let label: String
    let value: String
}
```

**Usage:**
```swift
DetailRow(
    label: "Kategori",
    value: transaction["category"] as? String ?? "-"
)
```

---

## State Management

### Main Screen State
```swift
@StateObject private var viewModel = AIViewModel()
@State private var prompt = ""
@State private var showResult = false
@State private var generatedTransaction: [String: Any]?
@State private var isLoading = false
```

### Result Sheet State
```swift
@Binding var isPresented: Bool
@State private var isSaving = false
```

---

## User Flow

### 1. Input Transaction Description
```
User opens Buatin Screen
    ↓
User enters description (e.g., "Beli makan siang di restoran ABC sebesar 50 ribu")
    ↓
User taps "Buatin Sekarang"
```

### 2. AI Processing
```
App sends prompt to /api/buatin endpoint
    ↓
AI analyzes and extracts transaction details
    ↓
API returns generated transaction data
```

### 3. Review & Confirm
```
Result sheet shows generated transaction
    ↓
User reviews details (title, amount, category, etc.)
    ↓
User taps "Simpan Transaksi" or "Batal"
```

### 4. Save Transaction
```
If Simpan: Transaction saved to backend
    ↓
Sheet closes, user returns to main screen
    ↓
Success notification (optional)

If Batal: Sheet closes without saving
    ↓
User returns to main screen
```

---

## API Integration

### Generate Transaction
```swift
let response = try await AIService.shared.generateTransaction(prompt: prompt)
```

**Request:**
```json
{
  "prompt": "Beli makan siang di restoran ABC sebesar 50 ribu"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "type": "expense",
    "title": "Makan Siang",
    "merchant": "Restoran ABC",
    "amount": 50000,
    "category": "Makanan & Minuman",
    "category_id": 1,
    "payment_method": "Tunai",
    "payment_method_id": 1,
    "date": "2024-01-15T12:30:00Z",
    "note": "Makan dengan teman",
    "confidence": 0.95
  }
}
```

---

## Error Handling

### Validation Errors
```swift
// Empty prompt
"Prompt tidak boleh kosong"

// API errors
- 422 Unprocessable Entity: "Unable to parse transaction from prompt"
- 401 Unauthorized: "Unauthorized. Please login first."
- 500 Server Error: "Internal server error"
```

### User Feedback
```swift
@State private var errorMessage = ""
@State private var showError = false

// Show error alert
.alert("Error", isPresented: $showError) {
    Button("OK") { }
} message: {
    Text(errorMessage)
}
```

---

## Quick Templates

### Template 1: Makan
```swift
QuickTemplateButton(
    icon: "🍔",
    title: "Makan",
    action: { prompt = "Makan siang di restoran" }
)
```

### Template 2: Transportasi
```swift
QuickTemplateButton(
    icon: "🚕",
    title: "Transportasi",
    action: { prompt = "Naik taksi/ojek" }
)
```

### Template 3: Belanja
```swift
QuickTemplateButton(
    icon: "🛍️",
    title: "Belanja",
    action: { prompt = "Belanja kebutuhan" }
)
```

### Template 4: Pemasukan
```swift
QuickTemplateButton(
    icon: "💰",
    title: "Pemasukan",
    action: { prompt = "Pemasukan dari pekerjaan" }
)
```

---

## Integration with MainTabView

### Floating Button
```swift
struct FloatingBuatinButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Buatin")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
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
            .cornerRadius(28)
            .shadow(color: Color(red: 0.4, green: 0.8, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}
```

### Sheet Presentation
```swift
@State private var showBuatin = false

.sheet(isPresented: $showBuatin) {
    BuatinScreen()
}
```

---

## Best Practices

### For Users
1. **Provide Clear Descriptions**
   - Good: "Beli makan siang di restoran ABC sebesar 50 ribu"
   - Bad: "makan"

2. **Include Amount**
   - Always include transaction amount
   - Use clear format: "50 ribu", "50000", "Rp 50.000"

3. **Specify Merchant**
   - Include merchant/vendor name when possible
   - Helps with categorization

4. **Add Context**
   - Include payment method if relevant
   - Mention date if not today
   - Add any relevant notes

### For Developers
1. **Error Handling**
   - Always handle API errors gracefully
   - Show user-friendly error messages
   - Provide suggestions for rephrasing

2. **Loading States**
   - Show loading indicator during processing
   - Disable buttons while loading
   - Provide feedback to user

3. **Validation**
   - Validate prompt before sending
   - Check confidence score in response
   - Ask for confirmation if confidence < 0.7

4. **Testing**
   - Test with various prompt formats
   - Test error scenarios
   - Test with different transaction types

---

## Example Prompts

### Expense Examples
```
"Beli kopi di Starbucks 35 ribu"
"Bayar tagihan listrik 250 ribu via transfer"
"Belanja groceries di Indomaret 150 ribu"
"Naik Gojek ke kantor 25 ribu"
"Bayar cicilan motor 2 juta"
```

### Income Examples
```
"Terima gaji bulanan 5 juta dari PT ABC"
"Bonus tahun ini 10 juta"
"Komisi penjualan 500 ribu"
"Freelance project 2 juta"
"Penjualan barang bekas 300 ribu"
```

### Complex Examples
```
"Bayar tagihan listrik bulan ini 250 ribu via transfer ke PLN, sudah bayar kemarin"
"Beli makan siang di restoran ABC sebesar 50 ribu dengan teman, pakai kartu kredit BCA"
"Terima gaji bulanan Januari sebesar 5 juta dari PT ABC via transfer bank"
```

---

## Future Enhancements

1. **Receipt Scanning**
   - Upload receipt image
   - OCR to extract transaction details
   - Auto-fill form

2. **Voice Input**
   - Voice-to-text for prompt
   - Natural language processing
   - Hands-free transaction creation

3. **Smart Suggestions**
   - Suggest categories based on history
   - Suggest merchants based on location
   - Suggest amounts based on patterns

4. **Batch Processing**
   - Create multiple transactions at once
   - Import from CSV
   - Sync with bank statements

5. **Confidence Feedback**
   - Show confidence score to user
   - Ask for confirmation if low confidence
   - Learn from user corrections

---

## Testing Checklist

- [ ] Input field accepts text
- [ ] Quick template buttons work
- [ ] Generate button disabled when prompt empty
- [ ] Loading state shows during processing
- [ ] Result sheet displays correctly
- [ ] Transaction details show correctly
- [ ] Save button saves transaction
- [ ] Cancel button closes sheet
- [ ] Error handling works
- [ ] Navigation works correctly
- [ ] Floating button appears in MainTabView
- [ ] Sheet presentation works

---

## Troubleshooting

### Prompt not being sent
1. Check if prompt is not empty
2. Verify internet connection
3. Check API endpoint is correct
4. Check authentication token

### Result not showing
1. Check API response format
2. Verify data extraction
3. Check error handling
4. Review console logs

### Save not working
1. Check if transaction data is valid
2. Verify API endpoint for save
3. Check authentication
4. Review error messages

### UI not displaying correctly
1. Check screen size/orientation
2. Verify color values
3. Check font sizes
4. Review layout constraints
