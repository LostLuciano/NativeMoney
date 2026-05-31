# MonassistNative - Design Quick Reference Guide

## Color Palette

### Primary Colors
```swift
ColorTokens.primaryGreen      // #267B5A - Main brand color
ColorTokens.neonGreen         // #33CC80 - Accent/highlight color
```

### Background
```swift
ColorTokens.darkBackground    // #141416 - Main background
ColorTokens.cardBackground    // #1F1F26 - Card background
```

### Status Colors
```swift
ColorTokens.successGreen      // #33CC66 - Success/income
ColorTokens.dangerRed         // #E63333 - Danger/expense
ColorTokens.warningYellow     // #FFBF33 - Warning
```

### Text Colors
```swift
ColorTokens.textPrimary       // #F2F2F7 - Main text
ColorTokens.textSecondary     // #999AAA - Secondary text
```

## Premium Gradient Background

Use this on all main screens:

```swift
LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 0.05, green: 0.05, blue: 0.15),
        Color(red: 0.08, green: 0.08, blue: 0.2)
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
.ignoresSafeArea()
```

## Liquid Glass Cards

### Basic Card
```swift
LiquidGlassCard(cornerRadius: 24, padding: 16) {
    // Content here
}
```

### Card with Glow (Premium)
```swift
LiquidGlassCard(cornerRadius: 28, padding: 24, showGlow: true) {
    // Content here
}
```

### Card without Border
```swift
LiquidGlassCard(cornerRadius: 20, padding: 16, showBorder: false) {
    // Content here
}
```

## Buttons

### Primary Button
```swift
LiquidGlassButton(
    title: "Save",
    icon: "checkmark",
    style: .primary,
    action: { /* action */ }
)
```

### Secondary Button
```swift
LiquidGlassButton(
    title: "Cancel",
    style: .secondary,
    action: { /* action */ }
)
```

### Danger Button
```swift
LiquidGlassButton(
    title: "Delete",
    icon: "trash.fill",
    style: .danger,
    action: { /* action */ }
)
```

## Typography

### Screen Title
```swift
Text("Title")
    .font(TypographyTokens.headlineLarge)
    .foregroundColor(ColorTokens.textPrimary)
```

### Section Title
```swift
Text("Section")
    .font(TypographyTokens.headlineSmall)
    .foregroundColor(ColorTokens.textPrimary)
```

### Card Title
```swift
Text("Card Title")
    .font(TypographyTokens.titleMedium)
    .foregroundColor(ColorTokens.textPrimary)
```

### Label
```swift
Text("Label")
    .font(TypographyTokens.labelMedium)
    .foregroundColor(ColorTokens.textSecondary)
```

### Body Text
```swift
Text("Body text")
    .font(TypographyTokens.bodySmall)
    .foregroundColor(ColorTokens.textSecondary)
```

### Caption
```swift
Text("Caption")
    .font(TypographyTokens.captionSmall)
    .foregroundColor(ColorTokens.textSecondary)
```

## Common Patterns

### Header with Back Button
```swift
HStack {
    Button(action: { dismiss() }) {
        Image(systemName: "chevron.left")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(ColorTokens.neonGreen)
    }
    
    Spacer()
    
    Text("Title")
        .font(TypographyTokens.headlineSmall)
        .foregroundColor(ColorTokens.textPrimary)
    
    Spacer()
    
    Button(action: { /* action */ }) {
        Image(systemName: "xmark")
            .foregroundColor(ColorTokens.textSecondary)
    }
}
.padding(16)
```

### Amount Display
```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Label")
        .font(TypographyTokens.labelSmall)
        .foregroundColor(ColorTokens.textSecondary)
    
    Text(formatCurrency(amount))
        .font(TypographyTokens.displaySmall)
        .foregroundColor(ColorTokens.textPrimary)
}
```

### Progress Bar
```swift
ZStack(alignment: .leading) {
    RoundedRectangle(cornerRadius: 6)
        .fill(ColorTokens.cardBackground)
    
    RoundedRectangle(cornerRadius: 6)
        .fill(ColorTokens.neonGreen)
        .frame(width: CGFloat(progress) * maxWidth)
}
.frame(height: 6)
```

### Icon with Label
```swift
HStack(spacing: 8) {
    Image(systemName: "icon.name")
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(ColorTokens.neonGreen)
    
    Text("Label")
        .font(TypographyTokens.labelSmall)
        .foregroundColor(ColorTokens.textSecondary)
}
```

### Status Badge
```swift
HStack(spacing: 8) {
    Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 12, weight: .semibold))
    
    Text("Status")
        .font(TypographyTokens.labelSmall)
}
.foregroundColor(ColorTokens.successGreen)
.padding(8)
.background(ColorTokens.successGreen.opacity(0.1))
.cornerRadius(8)
```

## Animations

### Spring Animation (Button Press)
```swift
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    // State change
}
```

### Ease In/Out (Modal)
```swift
withAnimation(.easeInOut(duration: 0.2)) {
    // State change
}
```

### Haptic Feedback
```swift
let impact = UIImpactFeedbackGenerator(style: .light)
impact.impactOccurred()
```

## Common Components

### Transaction Card
```swift
TransactionCard(
    transaction: transaction,
    category: category,
    onTap: { /* action */ }
)
```

### Budget Card
```swift
BudgetCard(
    budget: budget,
    category: category
)
```

### Insight Card
```swift
InsightCard(insight: insight)
```

### Empty State
```swift
EmptyStateView(
    icon: "list.bullet.rectangle",
    title: "No Data",
    message: "Create something to get started",
    actionTitle: "Create",
    action: { /* action */ }
)
```

### Loading State
```swift
LoadingSkeletonView()
```

### Error State
```swift
ErrorStateView(message: error) {
    // Retry action
}
```

## Screen Template

```swift
import SwiftUI

public struct NewScreen: View {
    @StateObject private var viewModel = NewViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Premium gradient background
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
                    Text("Title")
                        .font(TypographyTokens.headlineLarge)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Spacer()
                }
                .padding(16)
                
                // Content
                if viewModel.isLoading {
                    LoadingSkeletonView()
                } else if let error = viewModel.errorMessage {
                    ErrorStateView(message: error) {
                        Task {
                            await viewModel.load()
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Content here
                        }
                        .padding(16)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
```

## Spacing Guidelines

- **Padding:** 16pt (standard), 12pt (compact), 20pt (generous)
- **Spacing:** 20pt (sections), 12pt (items), 8pt (compact)
- **Corner Radius:** 24pt (cards), 12pt (buttons), 8pt (inputs)

## Icon Guidelines

- **Size:** 16pt (labels), 18pt (buttons), 20pt (navbar), 24pt (floating)
- **Weight:** semibold (standard), medium (secondary)
- **Color:** neonGreen (primary), textSecondary (inactive)

## Responsive Design

All screens use:
- `ignoresSafeArea()` for full-screen backgrounds
- `padding(.horizontal, 16)` for content margins
- `frame(maxWidth: .infinity)` for full-width elements
- `ScrollView` for scrollable content

## Dark Mode Support

All colors automatically adapt to dark mode through ColorTokens:
```swift
static func adaptiveBackground(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? darkBackground : Color.white
}
```

## Accessibility

- Always use `ColorTokens` for colors (ensures contrast)
- Provide `accessibilityLabel` for icons
- Support `reduceTransparency` environment variable
- Use semantic colors (success, danger, warning)

## Performance Tips

1. Use `@StateObject` for ViewModels
2. Use `@Published` for reactive updates
3. Use `async/await` for API calls
4. Avoid unnecessary view redraws
5. Use `.id()` for list items
6. Lazy load images with `AsyncImage`

## Common Mistakes to Avoid

1. ❌ Using `ColorTokens.darkBackground` instead of gradient
2. ❌ Forgetting `.ignoresSafeArea()` on backgrounds
3. ❌ Not using `LiquidGlassCard` for premium look
4. ❌ Inconsistent spacing and padding
5. ❌ Missing haptic feedback on interactions
6. ❌ Not handling loading/error states
7. ❌ Hardcoding colors instead of using tokens

## Resources

- **Design System:** `Design/ColorTokens.swift`, `Design/LiquidGlassEffect.swift`
- **Components:** `Design/ReusableComponents.swift`
- **Navigation:** `Design/CustomNavbar.swift`
- **Implementation Guide:** `LIQUID_GLASS_IMPLEMENTATION.md`
