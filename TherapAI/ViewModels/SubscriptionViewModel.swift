//
//  SubscriptionViewModel.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-01-07.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var subscriptionService = SubscriptionService.shared
    @Published var showingPaywall = false
    @Published var showingSubscriptionManagement = false
    @Published var purchaseError: String?
    @Published var isPurchasing = false
    
    // Premium feature flags
    var isPremiumUser: Bool {
        subscriptionService.hasActiveSubscription
    }
    
    var canAccessUnlimitedAI: Bool {
        isPremiumUser
    }
    
    var canAccessAdvancedInsights: Bool {
        isPremiumUser
    }
    
    var canExportJournal: Bool {
        isPremiumUser
    }
    
    // MARK: - Purchase Methods
    func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil
        
        do {
            let transaction = try await subscriptionService.purchase(product)
            if transaction != nil {
                // Purchase successful
                showingPaywall = false
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
        
        isPurchasing = false
    }
    
    func restorePurchases() async {
        await subscriptionService.restore()
    }
    
    func manageSubscriptions() {
        subscriptionService.manageSubscriptions()
    }
    
    // MARK: - Premium Feature Checks
    func checkPremiumAccess(feature: String, action: @escaping () -> Void) {
        if isPremiumUser {
            action()
        } else {
            showingPaywall = true
        }
    }
    
    func checkUnlimitedAIAccess(action: @escaping () -> Void) {
        checkPremiumAccess(feature: "unlimited AI") {
            action()
        }
    }
    
    // MARK: - Subscription Status Text
    var subscriptionStatusText: String {
        switch subscriptionService.subscriptionStatus {
        case .subscribed(let product):
            return "Active: \(product.displayName)"
        case .expired:
            return "No active subscription"
        case .inGracePeriod:
            return "In Grace Period"
        case .inBillingRetryPeriod:
            return "Billing Issue - Please Update Payment"
        case .revoked:
            return "Subscription Revoked"
        }
    }
    
    var subscriptionStatusColor: Color {
        switch subscriptionService.subscriptionStatus {
        case .subscribed:
            return .green
        case .expired:
            return .orange
        case .inGracePeriod:
            return .yellow
        case .inBillingRetryPeriod:
            return .red
        case .revoked:
            return .red
        }
    }
}