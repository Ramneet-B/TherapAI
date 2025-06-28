import Foundation
import SwiftUI
import StoreKit

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var subscriptionStatus: SubscriptionStatus = .trial
    @Published var trialDaysRemaining: Int = 3
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPlan: SubscriptionPlan = .monthly
    @Published var showingPaywall = false
    @Published var showingManageSubscription = false
    
    private let subscriptionService = SubscriptionService.shared
    private var user: User?
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe subscription service changes
        subscriptionService.$isLoading
            .assign(to: &$isLoading)
        
        subscriptionService.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Public Methods
    
    func updateUser(_ user: User) {
        self.user = user
        self.subscriptionStatus = user.subscriptionStatus
        self.trialDaysRemaining = user.trialDaysRemaining
        
        // Show paywall if trial expired
        if subscriptionService.isTrialExpired(for: user) {
            showingPaywall = true
        }
    }
    
    func checkSubscriptionAccess() -> Bool {
        guard let user = user else { return false }
        return subscriptionService.checkSubscriptionStatus(for: user)
    }
    
    func purchaseSubscription() async -> User? {
        guard let user = user else { return nil }
        
        let result = await subscriptionService.purchaseSubscription(plan: selectedPlan, for: user)
        
        switch result {
        case .success(let updatedUser):
            self.user = updatedUser
            self.subscriptionStatus = updatedUser.subscriptionStatus
            self.showingPaywall = false
            return updatedUser
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func restorePurchases() async {
        let result = await subscriptionService.restorePurchases()
        
        switch result {
        case .success:
            // Refresh user data after restore
            if let user = user {
                updateUser(user)
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func cancelSubscription() async -> User? {
        guard let user = user else { return nil }
        
        let result = await subscriptionService.cancelSubscription(for: user)
        
        switch result {
        case .success(let updatedUser):
            self.user = updatedUser
            self.subscriptionStatus = updatedUser.subscriptionStatus
            return updatedUser
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func dismissPaywall() {
        // Only allow dismissing if user still has access
        if let user = user, user.hasActiveAccess {
            showingPaywall = false
        }
    }
    
    func clearError() {
        errorMessage = nil
        subscriptionService.clearError()
    }
    
    // MARK: - Computed Properties
    
    var hasActiveSubscription: Bool {
        subscriptionStatus == .active
    }
    
    var isTrialActive: Bool {
        subscriptionStatus == .trial && trialDaysRemaining > 0
    }
    
    var isSubscriptionExpired: Bool {
        subscriptionStatus == .expired || subscriptionStatus == .cancelled
    }
    
    var shouldShowPaywall: Bool {
        guard let user = user else { return false }
        return !user.hasActiveAccess
    }
    
    var subscriptionStatusText: String {
        switch subscriptionStatus {
        case .trial:
            if trialDaysRemaining > 0 {
                return "Free Trial - \(trialDaysRemaining) day\(trialDaysRemaining == 1 ? "" : "s") remaining"
            } else {
                return "Free Trial Expired"
            }
        case .active:
            return "Active Subscription"
        case .expired:
            return "Subscription Expired"
        case .cancelled:
            return "Subscription Cancelled"
        }
    }
    
    var subscriptionStatusColor: Color {
        switch subscriptionStatus {
        case .trial:
            return trialDaysRemaining > 0 ? .blue : .orange
        case .active:
            return .green
        case .expired, .cancelled:
            return .red
        }
    }
    
    // MARK: - Trial Banner
    
    var shouldShowTrialBanner: Bool {
        return subscriptionStatus == .trial && trialDaysRemaining > 0
    }
    
    var trialBannerText: String {
        if trialDaysRemaining == 1 {
            return "Last day of free trial!"
        } else {
            return "\(trialDaysRemaining) days left in your free trial"
        }
    }
    
    var trialBannerColor: Color {
        switch trialDaysRemaining {
        case 0:
            return .red
        case 1:
            return .orange
        default:
            return .blue
        }
    }
}

// MARK: - Trial Banner View
struct TrialBannerView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    
    var body: some View {
        if subscriptionViewModel.shouldShowTrialBanner {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.white)
                
                Text(subscriptionViewModel.trialBannerText)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Upgrade") {
                    subscriptionViewModel.showingPaywall = true
                }
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(subscriptionViewModel.trialBannerColor)
            .cornerRadius(0)
        }
    }
}