//
//  SubscriptionService.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-01-07.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var products: [Product] = []
    @Published var subscriptionStatus: RenewalState = .expired
    @Published var isLoading = false
    @Published var purchaseError: Error?
    
    // Product IDs
    enum ProductID: String, CaseIterable {
        case weekly = "therapai_premium_weekly"
        case monthly = "therapai_premium_monthly"
        case yearly = "therapai_premium_yearly"
    }
    
    enum RenewalState {
        case subscribed(Product)
        case expired
        case inGracePeriod
        case inBillingRetryPeriod
        case revoked
    }
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted { product1, product2 in
                // Sort by price: weekly, monthly, yearly
                guard let price1 = product1.price as? Decimal,
                      let price2 = product2.price as? Decimal else {
                    return false
                }
                return price1 < price2
            }
        } catch {
            purchaseError = error
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Subscription Status
    func updateSubscriptionStatus() async {
        var validSubscription: Product?
        var currentStatus: RenewalState = .expired
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Find the product for this transaction
                if let product = products.first(where: { $0.id == transaction.productID }) {
                    validSubscription = product
                    
                    // Check subscription status
                    if let subscription = transaction.subscription {
                        switch subscription.status {
                        case .subscribed:
                            currentStatus = .subscribed(product)
                        case .expired:
                            currentStatus = .expired
                        case .inGracePeriod:
                            currentStatus = .inGracePeriod
                        case .inBillingRetryPeriod:
                            currentStatus = .inBillingRetryPeriod
                        case .revoked:
                            currentStatus = .revoked
                        @unknown default:
                            currentStatus = .expired
                        }
                    }
                }
            } catch {
                // Transaction verification failed
            }
        }
        
        subscriptionStatus = currentStatus
    }
    
    // MARK: - Transaction Verification
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    var isSubscribed: Bool {
        switch subscriptionStatus {
        case .subscribed:
            return true
        default:
            return false
        }
    }
    
    var hasActiveSubscription: Bool {
        switch subscriptionStatus {
        case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
            return true
        default:
            return false
        }
    }
    
    func restore() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            purchaseError = error
        }
    }
    
    func manageSubscriptions() {
        Task {
            if let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene {
                try? await AppStore.showManageSubscriptions(in: windowScene)
            }
        }
    }
}

// MARK: - StoreKit Error Extension
extension StoreKitError {
    static let failedVerification = StoreKitError(.unknown)
}