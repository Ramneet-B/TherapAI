import SwiftUI

struct MoodCheckInScreen: View {
    @EnvironmentObject var moodViewModel: MoodViewModel
    
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
                    
                    HStack(spacing: 16) {
                        ForEach(0..<moodViewModel.moods.count, id: \.self) { idx in
                            Button(action: { moodViewModel.selectedMood = idx }) {
                                Text(moodViewModel.moods[idx])
                                    .font(.system(size: 32))
                                    .frame(width: 60, height: 60)
                                    .background(moodViewModel.selectedMood == idx ? Color.purple.opacity(0.2) : Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(moodViewModel.selectedMood == idx ? Color.purple : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    TextField("Add a note (optional)", text: $moodViewModel.note)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.purple.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.purple.opacity(0.08), radius: 8, x: 0, y: 4)
                
                Button(action: { moodViewModel.saveMoodEntry() }) {
                    if moodViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(moodViewModel.selectedMood != nil ? Color.purple : Color.gray)
                .cornerRadius(16)
                .shadow(color: Color.purple.opacity(0.15), radius: 6, x: 0, y: 3)
                .disabled(moodViewModel.selectedMood == nil || moodViewModel.isLoading)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(moodViewModel.currentStreak)-day streak")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .alert("Mood Saved!", isPresented: $moodViewModel.showingSuccess) {
            Button("OK") { }
        }
    }
}

struct MoodCheckInScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoodCheckInScreen()
            .environmentObject(MoodViewModel())
    }
} 
