import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var subscriptionViewModel: SubscriptionViewModel
    @State private var showingSignOutAlert = false
    @State private var showingSubscriptionManagement = false
    
    private var user: User? {
        authViewModel.authState.user
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Profile Header
                    VStack(spacing: 15) {
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Text(user?.firstName.prefix(1).uppercased() ?? "U")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 5) {
                            Text(user?.fullName ?? "Unknown User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(user?.email ?? "No email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Subscription Status
                    if let currentUser = user {
                        VStack(spacing: 15) {
                            HStack {
                                Text("Subscription")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                showingSubscriptionManagement = true
                            }) {
                                VStack(spacing: 10) {
                                    HStack {
                                        Image(systemName: subscriptionStatusIcon(for: currentUser))
                                            .foregroundColor(subscriptionStatusColor(for: currentUser))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(currentUser.subscriptionStatus.displayName)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            Text(subscriptionStatusDescription(for: currentUser))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if currentUser.subscriptionStatus == .trial {
                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                            
                                            Text("\(currentUser.trialDaysRemaining) day\(currentUser.trialDaysRemaining == 1 ? "" : "s") left in trial")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    
                    // Profile Information
                    VStack(spacing: 15) {
                        ProfileInfoRow(
                            icon: "person.fill",
                            title: "Full Name",
                            value: user?.fullName ?? "Unknown User"
                        )
                        
                        ProfileInfoRow(
                            icon: "envelope.fill",
                            title: "Email",
                            value: user?.email ?? "No email"
                        )
                        
                        ProfileInfoRow(
                            icon: "calendar.badge.plus",
                            title: "Member Since",
                            value: formatDate(user?.createdAt ?? Date())
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Sign Out Button
                    VStack(spacing: 10) {
                        Button(action: {
                            showingSignOutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Sign Out")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Text("You can always sign back in later")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showingSubscriptionManagement) {
            if let currentUser = user {
                SubscriptionManagementView(
                    subscriptionViewModel: subscriptionViewModel,
                    user: currentUser
                )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func subscriptionStatusIcon(for user: User) -> String {
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
    
    private func subscriptionStatusColor(for user: User) -> Color {
        switch user.subscriptionStatus {
        case .trial:
            return user.trialDaysRemaining > 0 ? .blue : .orange
        case .active:
            return .green
        case .expired, .cancelled:
            return .red
        }
    }
    
    private func subscriptionStatusDescription(for user: User) -> String {
        switch user.subscriptionStatus {
        case .trial:
            return user.trialDaysRemaining > 0 ? "Free trial active" : "Trial expired"
        case .active:
            return "Premium subscription active"
        case .expired:
            return "Subscription expired"
        case .cancelled:
            return "Subscription cancelled"
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 25, height: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
            .environmentObject(AuthViewModel())
    }
}