import SwiftUI

struct HomeScreen: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome to TherapAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your personal mental wellness companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Main Features Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    HomeCard(
                        title: "Check-In",
                        subtitle: "How are you feeling today?",
                        icon: "face.smiling",
                        color: .purple,
                        action: {
                            selectedTab = .mood
                        }
                    )
                    
                    HomeCard(
                        title: "Journal",
                        subtitle: "Express your thoughts",
                        icon: "book.closed",
                        color: .blue,
                        action: {
                            selectedTab = .journal
                        }
                    )
                    
                    HomeCard(
                        title: "AI Chat",
                        subtitle: "Talk to your AI therapist",
                        icon: "bubble.left.and.bubble.right",
                        color: .green,
                        action: {
                            selectedTab = .chat
                        }
                    )
                    
                    HomeCard(
                        title: "Insights",
                        subtitle: "Track your progress",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange,
                        action: {
                            // Future feature - analytics
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Daily Quote Section
                VStack(spacing: 12) {
                    Text("Daily Affirmation")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\"You are stronger than you think, braver than you feel, and more loved than you know.\"")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Crisis Resources
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "phone.badge.plus")
                            .foregroundColor(.red)
                        Text("Need Immediate Help?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CrisisResourceButton(
                            title: "Crisis Hotline: 988",
                            subtitle: "24/7 Suicide & Crisis Lifeline",
                            action: {
                                if let url = URL(string: "tel://988") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        CrisisResourceButton(
                            title: "Crisis Text: HOME to 741741",
                            subtitle: "Free 24/7 crisis support",
                            action: {
                                if let url = URL(string: "sms://741741&body=HOME") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct HomeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CrisisResourceButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "phone.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeScreen(selectedTab: .constant(.home))
} 