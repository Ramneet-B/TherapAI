import SwiftUI

struct MainAppView: View {
    let user: User
    @EnvironmentObject var subscriptionViewModel: SubscriptionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Trial banner (if applicable)
                TrialBannerView(subscriptionViewModel: subscriptionViewModel)
                
                // Main app content
                ContentView()
            }
            
            // Paywall overlay
            if subscriptionViewModel.shouldShowPaywall {
                PaywallView(subscriptionViewModel: subscriptionViewModel)
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $subscriptionViewModel.showingPaywall) {
            PaywallView(subscriptionViewModel: subscriptionViewModel)
        }
        .onAppear {
            checkSubscriptionStatus()
        }
        .onChange(of: user) { newUser in
            subscriptionViewModel.updateUser(newUser)
        }
    }
    
    private func checkSubscriptionStatus() {
        // Update subscription view model with current user
        subscriptionViewModel.updateUser(user)
        
        // If user has no active access, show paywall
        if !user.hasActiveAccess {
            subscriptionViewModel.showingPaywall = true
        }
    }
}

// MARK: - Subscription Access Guard

struct SubscriptionAccessGuard<Content: View>: View {
    let user: User
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    let content: Content
    
    init(user: User, subscriptionViewModel: SubscriptionViewModel, @ViewBuilder content: () -> Content) {
        self.user = user
        self.subscriptionViewModel = subscriptionViewModel
        self.content = content()
    }
    
    var body: some View {
        Group {
            if user.hasActiveAccess {
                content
            } else {
                SubscriptionRequiredView(subscriptionViewModel: subscriptionViewModel)
            }
        }
    }
}

// MARK: - Subscription Required View

struct SubscriptionRequiredView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("Premium Feature")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This feature requires a premium subscription to access.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button("Upgrade to Premium") {
                subscriptionViewModel.showingPaywall = true
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Preview

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(email: "test@example.com", firstName: "Test", lastName: "User")
        
        MainAppView(user: user)
            .environmentObject(SubscriptionViewModel())
            .environmentObject(AuthViewModel())
    }
}