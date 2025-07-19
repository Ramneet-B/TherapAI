import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingSignOutAlert = false
    @State private var showingDisclaimer = false
    @State private var showingPrivacyPolicy = false
    
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
                    
                    // App Information & Legal
                    VStack(spacing: 15) {
                        SectionHeader(title: "App Information")
                        
                        VStack(spacing: 10) {
                            ProfileActionRow(
                                icon: "exclamationmark.triangle",
                                title: "Medical Disclaimers",
                                subtitle: "Important safety information",
                                iconColor: .orange
                            ) {
                                showingDisclaimer = true
                            }
                            
                            ProfileActionRow(
                                icon: "lock.shield",
                                title: "Privacy Policy",
                                subtitle: "How we protect your data",
                                iconColor: .green
                            ) {
                                showingPrivacyPolicy = true
                            }
                            
                            ProfileActionRow(
                                icon: "phone.badge.plus",
                                title: "Crisis Resources",
                                subtitle: "Emergency support contacts",
                                iconColor: .red
                            ) {
                                showingDisclaimer = true
                            }
                        }
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
        .sheet(isPresented: $showingDisclaimer) {
            DisclaimerView(isPresented: $showingDisclaimer)
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView(isPresented: $showingPrivacyPolicy)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 25, height: 25)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Privacy Policy View
struct PrivacyPolicyView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "md"),
                       let content = try? String(contentsOfFile: path) {
                        Text(content)
                            .font(.body)
                            .padding()
                    } else {
                        Text("Privacy Policy content will be loaded here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
            .environmentObject(AuthViewModel())
    }
}