# TherapAI Subscription System Guide

## Overview

TherapAI now includes a comprehensive subscription system with a **3-day free trial** and premium subscription options. Users get full access to all features during the trial period, after which they need to subscribe to continue using the app.

## 🏷️ Pricing Structure

- **Free Trial**: 3 days of full access (automatically starts on user registration)
- **Monthly Subscription**: $9.99/month
- **Yearly Subscription**: $79.99/year (33% savings - equivalent to $6.67/month)

## 🏗️ System Architecture

### Core Components

1. **Models** (`Models/User.swift`)
   - Updated `User` model with subscription fields
   - `SubscriptionStatus` enum (trial, active, expired, cancelled)
   - `SubscriptionPlan` enum (monthly, yearly)
   - `Subscription` struct for managing subscription data

2. **Services** (`Services/SubscriptionService.swift`)
   - Handles subscription logic and purchases
   - StoreKit integration for App Store purchases
   - Mock purchase implementation for testing
   - Trial management and validation

3. **ViewModels** (`ViewModels/SubscriptionViewModel.swift`)
   - Manages subscription state in the UI
   - Handles user interactions with subscription features
   - Trial banner and paywall presentation logic

4. **Views**
   - `PaywallView.swift`: Beautiful subscription purchase screen
   - `SubscriptionManagementView.swift`: User subscription management
   - `MainAppView.swift`: Orchestrates app flow with subscription checks
   - `TrialBannerView`: Shows trial countdown

## 🔄 User Flow

### New User Registration
1. User signs up → Trial automatically starts (3 days)
2. User gets full access to all features
3. Trial countdown banner appears in the app
4. On trial expiration → Paywall is presented

### Existing User Login
1. System checks subscription status
2. If trial expired or no active subscription → Shows paywall
3. If active subscription → Full access granted

### Subscription Purchase
1. User selects plan (monthly/yearly)
2. StoreKit handles purchase process
3. User model updated with subscription data
4. Full access restored

## 📱 UI Components

### Trial Banner
- Appears at the top of the main screen during trial
- Shows remaining days
- Quick upgrade button

### Paywall Screen
- Professional design with gradient background
- Feature highlights (Unlimited Chat, Mood Tracking, etc.)
- Two pricing options with "Best Value" badge
- Purchase and restore functionality

### Profile Integration
- Subscription status in user profile
- Direct access to subscription management
- Trial countdown display

### Subscription Management
- View current subscription status
- Cancel subscription
- Restore purchases
- Billing information

## 🔧 Technical Implementation

### User Model Updates
```swift
struct User {
    let subscriptionStatus: SubscriptionStatus
    let trialStartDate: Date
    let subscriptionEndDate: Date?
    
    var isTrialActive: Bool { /* logic */ }
    var trialDaysRemaining: Int { /* logic */ }
    var hasActiveAccess: Bool { /* logic */ }
}
```

### Subscription Service
```swift
class SubscriptionService {
    func checkSubscriptionStatus(for user: User) -> Bool
    func purchaseSubscription(plan: SubscriptionPlan, for user: User) async
    func cancelSubscription(for user: User) async
    func restorePurchases() async
}
```

### Access Control
The system uses `SubscriptionAccessGuard` to protect premium features:
```swift
SubscriptionAccessGuard(user: user, subscriptionViewModel: viewModel) {
    // Premium content here
}
```

## 🛡️ Security & Validation

- Server-side validation recommended for production
- StoreKit receipt verification
- Secure keychain storage for user data
- Trial period validation prevents manipulation

## 🎯 App Store Configuration

### Required Setup
1. **App Store Connect Configuration**
   - Create subscription products:
     - `com.therapai.monthly` ($9.99/month)
     - `com.therapai.yearly` ($79.99/year)
   
2. **StoreKit Configuration File** (for testing)
   - Add products with correct identifiers
   - Configure subscription groups

3. **App Capabilities**
   - Enable In-App Purchase capability
   - Add StoreKit framework

## 🔄 State Management

### Subscription States
- **Trial**: User in 3-day free trial
- **Active**: Paid subscription active
- **Expired**: Subscription expired, needs renewal
- **Cancelled**: User cancelled subscription

### App States
- **Loading**: Checking authentication/subscription
- **Trial Active**: User has access, trial banner shown
- **Trial Expired**: Paywall presented
- **Premium Active**: Full access, no restrictions

## 📊 Analytics Integration

Track key metrics:
- Trial conversion rate
- Churn rate
- Revenue per user
- Feature usage by subscription status

## 🧪 Testing

### Mock Implementation
- Uses local storage for testing
- Simulates purchase flows
- 2-second delay for realistic testing

### Production Testing
- Use StoreKit Testing in Xcode
- Test all purchase flows
- Verify subscription restoration

## 🚀 Deployment Checklist

### Pre-Launch
- [ ] Configure App Store Connect products
- [ ] Test purchase flows thoroughly
- [ ] Verify receipt validation
- [ ] Test subscription restoration
- [ ] Validate trial logic

### App Store Review
- [ ] Include subscription terms in app
- [ ] Privacy policy mentions subscriptions
- [ ] Clear subscription benefits explanation
- [ ] Restore purchases functionality

## 💡 Best Practices

### User Experience
- Clear value proposition in paywall
- Transparent pricing with no hidden fees
- Easy cancellation process
- Graceful handling of payment failures

### Technical
- Always verify purchases server-side in production
- Handle network failures gracefully
- Cache subscription status locally
- Regular subscription status refreshes

## 🔮 Future Enhancements

### Possible Additions
- Multiple subscription tiers
- Family sharing support
- Promotional offers and discounts
- Subscription analytics dashboard
- Push notifications for trial expiration

### Advanced Features
- Server-side subscription management
- Webhook integration for real-time updates
- Advanced analytics and reporting
- A/B testing for pricing strategies

## 📞 Troubleshooting

### Common Issues
1. **Purchases not working**: Check App Store Connect configuration
2. **Trial not expiring**: Verify date calculations
3. **Restore not working**: Ensure StoreKit is properly configured
4. **UI not updating**: Check observable object bindings

### Debug Tips
- Use Xcode's StoreKit testing
- Check console logs for subscription status
- Verify user model updates after purchases
- Test with different Apple ID accounts

## 📄 Legal Considerations

### Required Documentation
- Terms of Service (mention auto-renewal)
- Privacy Policy (data collection for subscriptions)
- Subscription terms clearly stated
- Cancellation policy

### Compliance
- Follow App Store Review Guidelines 3.1.2
- Implement proper purchase restoration
- Clear subscription benefits communication
- No misleading subscription terms

---

This subscription system provides a solid foundation for monetizing TherapAI while maintaining a great user experience. The 3-day trial gives users time to see the value, and the pricing structure is competitive for mental health apps in the market.