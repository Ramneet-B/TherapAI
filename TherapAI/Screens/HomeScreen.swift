import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemPurple).opacity(0.07).ignoresSafeArea()
                VStack(spacing: 32) {
                    Text("Home")
                        .font(.largeTitle).bold()
                        .foregroundColor(.black)
                        .padding(.top, 24)
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: MoodCheckInScreen()) {
                            HomeCard(title: "Daily Mood Check-In", subtitle: "Log your mood for today", icon: "face.smiling")
                        }
                        NavigationLink(destination: JournalScreen()) {
                            HomeCard(title: "Journal", subtitle: "Write about your thoughts and feelings", icon: "book.closed")
                        }
                        NavigationLink(destination: ChatScreen()) {
                            HomeCard(title: "Talk to the AI Therapist", subtitle: "Chat with the AI about anything on your mind", icon: "bubble.left.and.bubble.right")
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct HomeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.purple)
                .frame(width: 48, height: 48)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.purple.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
} 