import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: SubscriptionPlan = .yearly
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.3),
                    Color.indigo.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Subscription Plans
                    subscriptionPlansSection
                    
                    // Purchase Button
                    purchaseButton
                    
                    // Restore & Terms
                    bottomSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            subscriptionViewModel.selectedPlan = selectedPlan
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Close button (only if user still has access)
            HStack {
                Spacer()
                if !subscriptionViewModel.shouldShowPaywall {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // App Icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.purple)
                .padding(.bottom, 8)
            
            // Title
            Text("Unlock TherapAI Premium")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("Continue your mental wellness journey with unlimited access to AI-powered therapy sessions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                FeatureCard(
                    icon: "message.fill",
                    title: "Unlimited Chat",
                    description: "No limits on AI conversations"
                )
                
                FeatureCard(
                    icon: "heart.fill",
                    title: "Mood Tracking",
                    description: "Advanced mood analytics"
                )
                
                FeatureCard(
                    icon: "book.fill",
                    title: "Journal Insights",
                    description: "AI-powered journal analysis"
                )
                
                FeatureCard(
                    icon: "shield.fill",
                    title: "Privacy First",
                    description: "End-to-end encryption"
                )
            }
        }
    }
    
    // MARK: - Subscription Plans Section
    
    private var subscriptionPlansSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                // Yearly Plan (Recommended)
                PlanCard(
                    plan: .yearly,
                    isSelected: selectedPlan == .yearly,
                    isRecommended: true
                ) {
                    selectedPlan = .yearly
                    subscriptionViewModel.selectedPlan = .yearly
                }
                
                // Monthly Plan
                PlanCard(
                    plan: .monthly,
                    isSelected: selectedPlan == .monthly,
                    isRecommended: false
                ) {
                    selectedPlan = .monthly
                    subscriptionViewModel.selectedPlan = .monthly
                }
            }
        }
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await purchaseSubscription()
                }
            }) {
                HStack {
                    if subscriptionViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(subscriptionViewModel.isLoading ? "Processing..." : "Start Premium")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .disabled(subscriptionViewModel.isLoading)
            
            // Trial info
            if subscriptionViewModel.isTrialActive {
                Text("Your trial will automatically convert to a paid subscription")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Bottom Section
    
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Restore Purchases
            Button("Restore Purchases") {
                Task {
                    await subscriptionViewModel.restorePurchases()
                }
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            
            // Terms and Privacy
            HStack(spacing: 20) {
                Button("Terms of Service") {
                    // Handle terms
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Button("Privacy Policy") {
                    // Handle privacy
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Error message
            if let errorMessage = subscriptionViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    
    private func purchaseSubscription() async {
        if let updatedUser = await subscriptionViewModel.purchaseSubscription() {
            // Purchase successful, dismiss paywall
            dismiss()
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(plan.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if isRecommended {
                                Text("BEST VALUE")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.green)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(plan.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(plan.priceString)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(plan.monthlyEquivalent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected")
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.purple : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(subscriptionViewModel: SubscriptionViewModel())
    }
}