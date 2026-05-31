# MoneyAssist Database Schema

## Overview
Database schema untuk aplikasi MoneyAssist menggunakan MySQL/PostgreSQL dengan Laravel migrations.

---

## Tables

### 1. users
Tabel untuk menyimpan data pengguna aplikasi.

```sql
CREATE TABLE users (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  email_verified_at TIMESTAMP NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NULL,
  avatar_url VARCHAR(255) NULL,
  bio TEXT NULL,
  currency VARCHAR(3) DEFAULT 'IDR',
  language VARCHAR(5) DEFAULT 'id',
  theme VARCHAR(20) DEFAULT 'dark',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  telegram_id BIGINT NULL UNIQUE,
  remember_token VARCHAR(100) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  INDEX idx_email (email),
  INDEX idx_telegram_id (telegram_id),
  INDEX idx_created_at (created_at)
);
```

### 2. categories
Tabel untuk menyimpan kategori transaksi.

```sql
CREATE TABLE categories (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(50) NOT NULL,
  color VARCHAR(7) NOT NULL,
  type ENUM('income', 'expense') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_type (type),
  UNIQUE KEY unique_user_category (user_id, name)
);
```

### 3. payment_methods
Tabel untuk menyimpan metode pembayaran.

```sql
CREATE TABLE payment_methods (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  type ENUM('cash', 'card', 'bank_transfer', 'e_wallet') NOT NULL,
  icon VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  UNIQUE KEY unique_user_payment_method (user_id, name)
);
```

### 4. transactions
Tabel untuk menyimpan data transaksi.

```sql
CREATE TABLE transactions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('income', 'expense') NOT NULL,
  title VARCHAR(255) NOT NULL,
  merchant VARCHAR(255) NULL,
  amount DECIMAL(15, 2) NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  payment_method_id BIGINT UNSIGNED NULL,
  note TEXT NULL,
  transaction_date DATETIME NOT NULL,
  receipt_image_url VARCHAR(255) NULL,
  location_name VARCHAR(255) NULL,
  latitude DECIMAL(10, 8) NULL,
  longitude DECIMAL(11, 8) NULL,
  is_favorite BOOLEAN DEFAULT FALSE,
  is_pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_category_id (category_id),
  INDEX idx_payment_method_id (payment_method_id),
  INDEX idx_transaction_date (transaction_date),
  INDEX idx_type (type),
  INDEX idx_is_favorite (is_favorite),
  INDEX idx_is_pinned (is_pinned),
  INDEX idx_user_transaction_date (user_id, transaction_date)
);
```

### 5. budgets
Tabel untuk menyimpan data budget.

```sql
CREATE TABLE budgets (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  limit_amount DECIMAL(15, 2) NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_category_id (category_id),
  INDEX idx_month_year (month, year),
  UNIQUE KEY unique_user_category_month_year (user_id, category_id, month, year)
);
```

### 6. receipts
Tabel untuk menyimpan data struk/receipt.

```sql
CREATE TABLE receipts (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  transaction_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  ocr_text LONGTEXT NULL,
  extracted_json JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  INDEX idx_transaction_id (transaction_id),
  UNIQUE KEY unique_transaction_receipt (transaction_id)
);
```

### 7. ai_insights
Tabel untuk menyimpan AI insights.

```sql
CREATE TABLE ai_insights (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('spending_alert', 'saving_tip', 'category_insight', 'trend_analysis') NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  period VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_type (type),
  INDEX idx_created_at (created_at)
);
```

### 8. user_settings
Tabel untuk menyimpan user settings.

```sql
CREATE TABLE user_settings (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  theme VARCHAR(20) DEFAULT 'dark',
  language VARCHAR(5) DEFAULT 'id',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  app_lock_enabled BOOLEAN DEFAULT FALSE,
  biometric_enabled BOOLEAN DEFAULT FALSE,
  auto_lock_timeout INT DEFAULT 300,
  glass_intensity FLOAT DEFAULT 1.0,
  reduce_transparency BOOLEAN DEFAULT FALSE,
  enable_haptics BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

### 9. personal_access_tokens
Tabel untuk Sanctum tokens (Laravel default).

```sql
CREATE TABLE personal_access_tokens (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tokenable_type VARCHAR(255) NOT NULL,
  tokenable_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(255) NOT NULL,
  token VARCHAR(64) UNIQUE NOT NULL,
  abilities LONGTEXT NULL,
  last_used_at TIMESTAMP NULL,
  expires_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_tokenable_type_id (tokenable_type, tokenable_id),
  INDEX idx_token (token)
);
```

---

## Relationships

```
users
  ├── has many categories
  ├── has many payment_methods
  ├── has many transactions
  ├── has many budgets
  ├── has many ai_insights
  └── has one user_settings

categories
  ├── belongs to user
  └── has many transactions

payment_methods
  ├── belongs to user
  └── has many transactions

transactions
  ├── belongs to user
  ├── belongs to category
  ├── belongs to payment_method
  └── has one receipt

budgets
  ├── belongs to user
  └── belongs to category

receipts
  └── belongs to transaction

ai_insights
  └── belongs to user

user_settings
  └── belongs to user
```

---

## Indexes

### Performance Indexes
```sql
-- Transactions queries
CREATE INDEX idx_user_transaction_date ON transactions(user_id, transaction_date DESC);
CREATE INDEX idx_user_category_date ON transactions(user_id, category_id, transaction_date DESC);
CREATE INDEX idx_user_type_date ON transactions(user_id, type, transaction_date DESC);

-- Budget queries
CREATE INDEX idx_user_budget_month_year ON budgets(user_id, month, year);

-- Category queries
CREATE INDEX idx_user_category_type ON categories(user_id, type);

-- AI Insights queries
CREATE INDEX idx_user_insights_date ON ai_insights(user_id, created_at DESC);
```

---

## Migrations (Laravel)

### Create Users Table
```php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->string('phone')->nullable();
    $table->string('avatar_url')->nullable();
    $table->text('bio')->nullable();
    $table->string('currency', 3)->default('IDR');
    $table->string('language', 5)->default('id');
    $table->string('theme', 20)->default('dark');
    $table->boolean('notifications_enabled')->default(true);
    $table->bigInteger('telegram_id')->nullable()->unique();
    $table->rememberToken();
    $table->timestamps();
    $table->softDeletes();
    
    $table->index('email');
    $table->index('telegram_id');
    $table->index('created_at');
});
```

### Create Categories Table
```php
Schema::create('categories', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('name', 100);
    $table->string('icon', 50);
    $table->string('color', 7);
    $table->enum('type', ['income', 'expense']);
    $table->timestamps();
    $table->softDeletes();
    
    $table->unique(['user_id', 'name']);
    $table->index('type');
});
```

### Create Payment Methods Table
```php
Schema::create('payment_methods', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('name', 100);
    $table->enum('type', ['cash', 'card', 'bank_transfer', 'e_wallet']);
    $table->string('icon', 50);
    $table->timestamps();
    $table->softDeletes();
    
    $table->unique(['user_id', 'name']);
});
```

### Create Transactions Table
```php
Schema::create('transactions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->enum('type', ['income', 'expense']);
    $table->string('title');
    $table->string('merchant')->nullable();
    $table->decimal('amount', 15, 2);
    $table->foreignId('category_id')->constrained()->restrictOnDelete();
    $table->foreignId('payment_method_id')->nullable()->constrained()->nullOnDelete();
    $table->text('note')->nullable();
    $table->dateTime('transaction_date');
    $table->string('receipt_image_url')->nullable();
    $table->string('location_name')->nullable();
    $table->decimal('latitude', 10, 8)->nullable();
    $table->decimal('longitude', 11, 8)->nullable();
    $table->boolean('is_favorite')->default(false);
    $table->boolean('is_pinned')->default(false);
    $table->timestamps();
    $table->softDeletes();
    
    $table->index('user_id');
    $table->index('category_id');
    $table->index('payment_method_id');
    $table->index('transaction_date');
    $table->index('type');
    $table->index('is_favorite');
    $table->index('is_pinned');
    $table->index(['user_id', 'transaction_date']);
});
```

### Create Budgets Table
```php
Schema::create('budgets', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('category_id')->constrained()->cascadeOnDelete();
    $table->decimal('limit_amount', 15, 2);
    $table->integer('month');
    $table->integer('year');
    $table->timestamps();
    $table->softDeletes();
    
    $table->unique(['user_id', 'category_id', 'month', 'year']);
    $table->index(['month', 'year']);
});
```

### Create Receipts Table
```php
Schema::create('receipts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('transaction_id')->constrained()->cascadeOnDelete();
    $table->string('image_url');
    $table->longText('ocr_text')->nullable();
    $table->json('extracted_json')->nullable();
    $table->timestamps();
    $table->softDeletes();
    
    $table->unique('transaction_id');
});
```

### Create AI Insights Table
```php
Schema::create('ai_insights', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->enum('type', ['spending_alert', 'saving_tip', 'category_insight', 'trend_analysis']);
    $table->string('title');
    $table->text('message');
    $table->string('period');
    $table->timestamps();
    $table->softDeletes();
    
    $table->index('user_id');
    $table->index('type');
    $table->index('created_at');
});
```

### Create User Settings Table
```php
Schema::create('user_settings', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
    $table->string('theme', 20)->default('dark');
    $table->string('language', 5)->default('id');
    $table->boolean('notifications_enabled')->default(true);
    $table->boolean('app_lock_enabled')->default(false);
    $table->boolean('biometric_enabled')->default(false);
    $table->integer('auto_lock_timeout')->default(300);
    $table->float('glass_intensity')->default(1.0);
    $table->boolean('reduce_transparency')->default(false);
    $table->boolean('enable_haptics')->default(true);
    $table->timestamps();
});
```

---

## Seeding Default Data

### Default Categories
```php
Category::create([
    'user_id' => $user->id,
    'name' => 'Makanan',
    'icon' => 'fork.knife',
    'color' => '#FF6B6B',
    'type' => 'expense'
]);

Category::create([
    'user_id' => $user->id,
    'name' => 'Transportasi',
    'icon' => 'car.fill',
    'color' => '#4ECDC4',
    'type' => 'expense'
]);

// ... more categories
```

### Default Payment Methods
```php
PaymentMethod::create([
    'user_id' => $user->id,
    'name' => 'Tunai',
    'type' => 'cash',
    'icon' => 'banknote.fill'
]);

PaymentMethod::create([
    'user_id' => $user->id,
    'name' => 'Kartu Kredit',
    'type' => 'card',
    'icon' => 'creditcard.fill'
]);

// ... more payment methods
```

---

## Notes
- Semua timestamps menggunakan UTC
- Soft deletes digunakan untuk data integrity
- Foreign keys menggunakan cascade/restrict untuk data consistency
- Indexes dioptimalkan untuk query performance
- Currency disimpan sebagai DECIMAL untuk akurasi finansial
- Coordinates (latitude/longitude) menggunakan DECIMAL untuk presisi
