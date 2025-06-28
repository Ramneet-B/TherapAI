import Foundation
import StoreKit

class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var subscriptions: [Subscription] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let keychainService = KeychainService.shared
    
    // Product identifiers for App Store Connect
    private let monthlyProductID = "com.therapai.monthly"
    private let yearlyProductID = "com.therapai.yearly"
    
    private var products: [Product] = []
    
    private init() {
        loadSubscriptions()
    }
    
    // MARK: - Subscription Status
    
    func checkSubscriptionStatus(for user: User) -> Bool {
        return user.hasActiveAccess
    }
    
    func getTrialDaysRemaining(for user: User) -> Int {
        return user.trialDaysRemaining
    }
    
    func isTrialExpired(for user: User) -> Bool {
        return !user.isTrialActive && user.subscriptionStatus == .trial
    }
    
    // MARK: - Trial Management
    
    func startTrialForUser(_ user: User) -> User {
        // Trial is automatically started when user is created
        return user
    }
    
    // MARK: - Subscription Purchase (Mock Implementation)
    
    func purchaseSubscription(plan: SubscriptionPlan, for user: User) async -> Result<User, SubscriptionError> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate purchase delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Mock successful purchase
        let subscription = Subscription(userId: user.id, plan: plan)
        subscriptions.append(subscription)
        saveSubscriptions()
        
        // Update user with active subscription
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt,
            subscriptionStatus: .active,
            trialStartDate: user.trialStartDate,
            subscriptionEndDate: subscription.endDate
        )
        
        // Save updated user data
        _ = keychainService.save(updatedUser, for: .userData)
        
        await MainActor.run {
            isLoading = false
        }
        
        return .success(updatedUser)
    }
    
    // MARK: - StoreKit Integration (Production Ready)
    
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [monthlyProductID, yearlyProductID])
            await MainActor.run {
                self.products = storeProducts
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load subscription products: \(error.localizedDescription)"
            }
        }
    }
    
    func purchaseProduct(_ product: Product, for user: User) async -> Result<User, SubscriptionError> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Handle successful purchase
                    let plan: SubscriptionPlan = product.id == monthlyProductID ? .monthly : .yearly
                    let subscription = Subscription(userId: user.id, plan: plan)
                    subscriptions.append(subscription)
                    saveSubscriptions()
                    
                    // Update user
                    let updatedUser = User(
                        id: user.id,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        createdAt: user.createdAt,
                        lastLoginAt: user.lastLoginAt,
                        subscriptionStatus: .active,
                        trialStartDate: user.trialStartDate,
                        subscriptionEndDate: subscription.endDate
                    )
                    
                    _ = keychainService.save(updatedUser, for: .userData)
                    
                    await transaction.finish()
                    
                    await MainActor.run {
                        isLoading = false
                    }
                    
                    return .success(updatedUser)
                    
                case .unverified:
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Purchase verification failed"
                    }
                    return .failure(.verificationFailed)
                }
                
            case .userCancelled:
                await MainActor.run {
                    isLoading = false
                }
                return .failure(.userCancelled)
                
            case .pending:
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Purchase is pending approval"
                }
                return .failure(.purchasePending)
                
            @unknown default:
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Unknown purchase result"
                }
                return .failure(.unknown)
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Purchase failed: \(error.localizedDescription)"
            }
            return .failure(.purchaseFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Subscription Management
    
    func cancelSubscription(for user: User) async -> Result<User, SubscriptionError> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // In a real app, this would cancel the subscription via StoreKit/App Store
        // For now, we'll just update the local status
        
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt,
            subscriptionStatus: .cancelled,
            trialStartDate: user.trialStartDate,
            subscriptionEndDate: user.subscriptionEndDate
        )
        
        _ = keychainService.save(updatedUser, for: .userData)
        
        await MainActor.run {
            isLoading = false
        }
        
        return .success(updatedUser)
    }
    
    func restorePurchases() async -> Result<Bool, SubscriptionError> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await AppStore.sync()
            
            // Check for active subscriptions
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    // Handle verified transaction
                    print("Restored transaction: \(transaction.productID)")
                case .unverified:
                    print("Unverified transaction found")
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
            
            return .success(true)
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            }
            return .failure(.restoreFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveSubscriptions() {
        // In a real app, this would save to your backend
        // For now, we'll use UserDefaults for simplicity
        if let data = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(data, forKey: "subscriptions")
        }
    }
    
    private func loadSubscriptions() {
        if let data = UserDefaults.standard.data(forKey: "subscriptions"),
           let loadedSubscriptions = try? JSONDecoder().decode([Subscription].self, from: data) {
            subscriptions = loadedSubscriptions
        }
    }
    
    // MARK: - Helper Methods
    
    func getProduct(for plan: SubscriptionPlan) -> Product? {
        let productId = plan == .monthly ? monthlyProductID : yearlyProductID
        return products.first { $0.id == productId }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

enum SubscriptionError: LocalizedError {
    case userCancelled
    case purchaseFailed(String)
    case verificationFailed
    case purchasePending
    case restoreFailed(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .verificationFailed:
            return "Purchase verification failed"
        case .purchasePending:
            return "Purchase is pending approval"
        case .restoreFailed(let message):
            return "Failed to restore purchases: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}