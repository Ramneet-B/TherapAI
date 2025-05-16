import SwiftUI

struct MoodCheckInScreen: View {
    @State private var selectedMood: Int? = nil
    @State private var note: String = ""
    
    let moods = ["😞", "😐", "🙂", "😊", "😁"]
    
    var body: some View {
        ZStack {
            Color(.systemPurple).opacity(0.07).ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Mood Check-In")
                    .font(.largeTitle).bold()
                    .foregroundColor(.black)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("How are you feeling today?")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 24) {
                        ForEach(0..<moods.count, id: \.self) { idx in
                            Button(action: { selectedMood = idx }) {
                                Text(moods[idx])
                                    .font(.system(size: 36))
                                    .padding()
                                    .background(selectedMood == idx ? Color.purple.opacity(0.2) : Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedMood == idx ? Color.purple : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    TextField("Add a note (optional)", text: $note)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.purple.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.purple.opacity(0.08), radius: 8, x: 0, y: 4)
                
                Button(action: {}) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("5-day streak")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

struct MoodCheckInScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoodCheckInScreen()
    }
} 
