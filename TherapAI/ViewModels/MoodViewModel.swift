import Foundation
import SwiftUI

@MainActor
class MoodViewModel: ObservableObject {
    @Published var selectedMood: Int? = nil
    @Published var note: String = ""
    @Published var currentStreak: Int = 0
    @Published var moodEntries: [MoodEntry] = []
    @Published var isLoading: Bool = false
    @Published var showingSuccess: Bool = false
    
    let moods = ["😞", "😐", "🙂", "😊", "😁"]
    
    init() {
        loadMoodEntries()
        calculateStreak()
    }
    
    func saveMoodEntry() {
        guard let selectedMood = selectedMood else { return }
        
        isLoading = true
        
        let newEntry = MoodEntry(
            date: Date(),
            moodIndex: selectedMood,
            note: note.isEmpty ? nil : note,
            createdAt: Date()
        )
        
        moodEntries.insert(newEntry, at: 0)
        calculateStreak()
        resetForm()
        showingSuccess = true
        
        // Hide success message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showingSuccess = false
        }
        
        isLoading = false
    }
    
    func loadMoodEntries() {
        // For now, just keep existing entries in memory
        // This will be replaced with Core Data when entities are configured
    }
    
    func calculateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var streak = 0
        var currentDate = today
        
        // Check if there's an entry for each consecutive day
        while true {
            let hasEntryForDate = moodEntries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate)
            }
            
            if hasEntryForDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        currentStreak = streak
    }
    
    func hasEntryForToday() -> Bool {
        let calendar = Calendar.current
        return moodEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: Date())
        }
    }
    
    private func resetForm() {
        selectedMood = nil
        note = ""
    }
    
    func getMoodHistory(days: Int) -> [MoodEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return moodEntries.filter { entry in
            entry.date >= startDate
        }
    }
} 