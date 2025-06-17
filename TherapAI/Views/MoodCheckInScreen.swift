import SwiftUI

struct MoodCheckInScreen: View {
    @EnvironmentObject var moodViewModel: MoodViewModel
    @State private var selectedMood: String = ""
    @State private var notes: String = ""
    @State private var showingSuccessAlert = false
    
    let moods = [
        ("😄", "Amazing", Color.green),
        ("😊", "Good", Color.mint),
        ("😐", "Okay", Color.yellow),
        ("😔", "Not Great", Color.orange),
        ("😢", "Difficult", Color.red)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("How are you feeling?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Select your current mood and share any thoughts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Mood Selection
                VStack(spacing: 16) {
                    Text("Select Your Mood")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                        ForEach(moods, id: \.0) { emoji, label, color in
                            MoodCard(
                                emoji: emoji,
                                label: label,
                                color: color,
                                isSelected: selectedMood == label,
                                action: {
                                    selectedMood = label
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes (Optional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("How has your day been? What's on your mind?", text: $notes, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .lineLimit(3...6)
                }
                .padding(.horizontal)
                
                // Current Streak
                if moodViewModel.currentStreak > 0 {
                    VStack(spacing: 8) {
                        Text("🔥 Current Streak")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("\(moodViewModel.currentStreak) day\(moodViewModel.currentStreak == 1 ? "" : "s")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Submit Button
                Button(action: submitMoodEntry) {
                    Text("Save Check-In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMood.isEmpty ? Color.gray : Color.purple)
                        .cornerRadius(12)
                }
                .disabled(selectedMood.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .alert("Check-In Saved!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text("Your mood has been recorded. Keep up the great work!")
        }
    }
    
    private func submitMoodEntry() {
        // Map the selected mood to the correct index
        let moodIndex = moods.firstIndex { $0.1 == selectedMood } ?? 2
        
        // Set the values in the view model
        moodViewModel.selectedMood = moodIndex
        moodViewModel.note = notes
        
        // Save the entry
        moodViewModel.saveMoodEntry()
        
        showingSuccessAlert = true
    }
    
    private func clearForm() {
        selectedMood = ""
        notes = ""
    }
}

struct MoodCard: View {
    let emoji: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(isSelected ? color : Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoodCheckInScreen()
        .environmentObject(MoodViewModel())
} 