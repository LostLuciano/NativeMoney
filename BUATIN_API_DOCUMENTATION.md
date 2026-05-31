# Buatin API Documentation

## Overview
Endpoint untuk AI generate transaction berdasarkan deskripsi natural language dari user.

## Endpoint

### Generate Transaction
```
POST /api/buatin
Authorization: Bearer {token}
Content-Type: application/json
```

## Request

### Body Parameters
```json
{
  "prompt": "string (required) - Deskripsi transaksi dalam bahasa natural"
}
```

### Examples

#### Example 1: Expense Transaction
```json
{
  "prompt": "Beli makan siang di restoran ABC sebesar 50 ribu"
}
```

#### Example 2: Income Transaction
```json
{
  "prompt": "Terima gaji bulanan sebesar 5 juta dari perusahaan"
}
```

#### Example 3: Complex Transaction
```json
{
  "prompt": "Bayar tagihan listrik bulan ini sebesar 250 ribu via transfer bank"
}
```

## Response

### Success Response (200)
```json
{
  "success": true,
  "message": "Transaction generated successfully",
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
    "confidence": 0.95,
    "extracted_fields": {
      "amount": {
        "value": 50000,
        "confidence": 0.98
      },
      "merchant": {
        "value": "Restoran ABC",
        "confidence": 0.92
      },
      "category": {
        "value": "Makanan & Minuman",
        "confidence": 0.95
      },
      "type": {
        "value": "expense",
        "confidence": 1.0
      }
    }
  }
}
```

### Error Response (400)
```json
{
  "success": false,
  "message": "Invalid prompt format",
  "errors": {
    "prompt": ["Prompt tidak boleh kosong"]
  }
}
```

### Error Response (401)
```json
{
  "success": false,
  "message": "Unauthorized. Please login first."
}
```

### Error Response (422)
```json
{
  "success": false,
  "message": "Unable to parse transaction from prompt",
  "data": {
    "prompt": "Deskripsi yang diberikan",
    "suggestion": "Coba gunakan format: '[Tipe] [Jumlah] [Kategori] [Deskripsi]'"
  }
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Transaction ID |
| type | string | Transaction type (expense/income) |
| title | string | Transaction title |
| merchant | string | Merchant/vendor name |
| amount | float | Transaction amount |
| category | string | Category name |
| category_id | integer | Category ID |
| payment_method | string | Payment method name |
| payment_method_id | integer | Payment method ID |
| date | string | Transaction date (ISO 8601) |
| note | string | Additional notes |
| confidence | float | AI confidence score (0-1) |
| extracted_fields | object | Detailed extraction results with confidence scores |

## AI Parsing Rules

### Amount Detection
- Detects various formats: "50 ribu", "50000", "Rp 50.000", "50k"
- Converts to numeric value in IDR

### Category Detection
- Analyzes keywords to determine category
- Common categories: Makanan, Transportasi, Hiburan, Belanja, Tagihan, Gaji, Investasi
- Falls back to "Lainnya" if uncertain

### Type Detection
- Expense keywords: beli, bayar, belanja, makan, minum, naik, bayar
- Income keywords: terima, gaji, bonus, komisi, penjualan, transfer masuk

### Merchant Detection
- Extracts business/vendor names from prompt
- Recognizes common merchants and abbreviations

### Date Detection
- Defaults to current date/time if not specified
- Recognizes relative dates: "kemarin", "minggu lalu", "bulan lalu"
- Recognizes specific dates: "15 Januari", "2024-01-15"

## Examples

### Example 1: Simple Expense
**Request:**
```json
{
  "prompt": "Beli kopi di Starbucks 35 ribu"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "type": "expense",
    "title": "Kopi",
    "merchant": "Starbucks",
    "amount": 35000,
    "category": "Makanan & Minuman",
    "payment_method": "Tunai",
    "confidence": 0.98
  }
}
```

### Example 2: Income Transaction
**Request:**
```json
{
  "prompt": "Terima gaji bulan Januari sebesar 5 juta dari PT ABC"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "type": "income",
    "title": "Gaji",
    "merchant": "PT ABC",
    "amount": 5000000,
    "category": "Gaji",
    "payment_method": "Transfer Bank",
    "confidence": 0.99
  }
}
```

### Example 3: Complex Transaction
**Request:**
```json
{
  "prompt": "Bayar tagihan listrik bulan ini 250 ribu via transfer ke PLN, sudah bayar kemarin"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "type": "expense",
    "title": "Tagihan Listrik",
    "merchant": "PLN",
    "amount": 250000,
    "category": "Tagihan",
    "payment_method": "Transfer Bank",
    "date": "2024-01-14T00:00:00Z",
    "note": "Tagihan listrik bulan ini",
    "confidence": 0.96
  }
}
```

## Rate Limiting
- 30 requests per minute per user
- 500 requests per hour per user

## Notes
- AI parsing is not 100% accurate. Always review generated transactions before saving.
- Confidence score indicates how confident the AI is about the extraction.
- If confidence is below 0.7, consider asking user for confirmation.
- The API will attempt to extract as much information as possible from the prompt.
- If critical information (amount, type) cannot be extracted, the API will return 422 error.

## Best Practices

1. **Provide Clear Descriptions**
   - Good: "Beli makan siang di restoran ABC sebesar 50 ribu"
   - Bad: "makan"

2. **Include Amount**
   - Always include the transaction amount for better accuracy
   - Use clear format: "50 ribu", "50000", "Rp 50.000"

3. **Specify Merchant**
   - Include merchant/vendor name when possible
   - Helps with categorization and tracking

4. **Add Context**
   - Include payment method if relevant
   - Mention date if not today
   - Add any relevant notes

## Integration with Frontend

### Swift Example
```swift
let prompt = "Beli makan siang di restoran ABC sebesar 50 ribu"
let response = try await AIService.shared.generateTransaction(prompt: prompt)

if let data = response["data"] as? [String: Any] {
    // Use generated transaction data
    let title = data["title"] as? String
    let amount = data["amount"] as? Double
    let category = data["category"] as? String
}
```

### Error Handling
```swift
do {
    let response = try await AIService.shared.generateTransaction(prompt: prompt)
    // Handle success
} catch APIError.unprocessableEntity(let message) {
    // Handle parsing error - ask user to rephrase
    print("Unable to parse: \(message)")
} catch {
    // Handle other errors
    print("Error: \(error.localizedDescription)")
}
```
