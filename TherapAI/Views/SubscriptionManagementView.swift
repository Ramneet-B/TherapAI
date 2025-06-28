import SwiftUI

struct SubscriptionManagementView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Subscription Status
                    subscriptionStatusSection
                    
                    // Subscription Details
                    if user.subscriptionStatus == .active {
                        subscriptionDetailsSection
                    }
                    
                    // Trial Information
                    if user.subscriptionStatus == .trial {
                        trialInformationSection
                    }
                    
                    // Subscription Options
                    subscriptionOptionsSection
                    
                    // Account Actions
                    accountActionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Subscription Status Section
    
    private var subscriptionStatusSection: some View {
        VStack(spacing: 16) {
            // Status Icon
            Image(systemName: subscriptionStatusIcon)
                .font(.system(size: 40))
                .foregroundColor(subscriptionViewModel.subscriptionStatusColor)
            
            // Status Text
            Text(subscriptionViewModel.subscriptionStatusText)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Status Description
            Text(subscriptionStatusDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Subscription Details Section
    
    private var subscriptionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                SubscriptionDetailRow(
                    title: "Plan",
                    value: "Premium"
                )
                
                if let endDate = user.subscriptionEndDate {
                    SubscriptionDetailRow(
                        title: "Next Billing Date",
                        value: formatDate(endDate)
                    )
                }
                
                SubscriptionDetailRow(
                    title: "Status",
                    value: user.subscriptionStatus.displayName
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Trial Information Section
    
    private var trialInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Free Trial")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                SubscriptionDetailRow(
                    title: "Trial Started",
                    value: formatDate(user.trialStartDate)
                )
                
                let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: user.trialStartDate) ?? Date()
                SubscriptionDetailRow(
                    title: "Trial Ends",
                    value: formatDate(trialEndDate)
                )
                
                SubscriptionDetailRow(
                    title: "Days Remaining",
                    value: "\(user.trialDaysRemaining)"
                )
            }
            
            if user.trialDaysRemaining > 0 {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Your trial will automatically end after 3 days. No payment required.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Subscription Options Section
    
    private var subscriptionOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription Options")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if user.subscriptionStatus == .trial {
                    Button(action: {
                        subscriptionViewModel.showingPaywall = true
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to Premium")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("Get unlimited access to all features")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: {
                    Task {
                        await subscriptionViewModel.restorePurchases()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Restore previous purchases")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if subscriptionViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(subscriptionViewModel.isLoading)
            }
        }
    }
    
    // MARK: - Account Actions Section
    
    private var accountActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if user.subscriptionStatus == .active {
                    Button(action: {
                        Task {
                            await cancelSubscription()
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cancel Subscription")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("Cancel your current subscription")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Terms and Privacy
                HStack(spacing: 20) {
                    Button("Terms of Service") {
                        // Handle terms
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Privacy Policy") {
                        // Handle privacy
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var subscriptionStatusIcon: String {
        switch user.subscriptionStatus {
        case .trial:
            return user.trialDaysRemaining > 0 ? "clock.fill" : "clock.badge.exclamationmark"
        case .active:
            return "checkmark.circle.fill"
        case .expired:
            return "exclamationmark.triangle.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
    
    private var subscriptionStatusDescription: String {
        switch user.subscriptionStatus {
        case .trial:
            if user.trialDaysRemaining > 0 {
                return "Enjoy full access to all premium features during your free trial."
            } else {
                return "Your free trial has ended. Upgrade to continue using premium features."
            }
        case .active:
            return "You have full access to all premium features."
        case .expired:
            return "Your subscription has expired. Renew to continue using premium features."
        case .cancelled:
            return "Your subscription has been cancelled. You can reactivate it anytime."
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func cancelSubscription() async {
        if let _ = await subscriptionViewModel.cancelSubscription() {
            // Subscription cancelled successfully
        }
    }
}

// MARK: - Subscription Detail Row

struct SubscriptionDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

struct SubscriptionManagementView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(email: "test@example.com", firstName: "Test", lastName: "User")
        
        SubscriptionManagementView(
            subscriptionViewModel: SubscriptionViewModel(),
            user: user
        )
    }
}