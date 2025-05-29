import Foundation

// Temporary struct-based model until Core Data entities are configured
struct MoodEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var moodIndex: Int
    var note: String?
    var createdAt: Date
    
    // Computed properties for easier use
    var moodEmoji: String {
        let moods = ["😞", "😐", "🙂", "😊", "😁"]
        return moods[moodIndex]
    }
    
    var moodDescription: String {
        let descriptions = ["Sad", "Neutral", "Happy", "Great", "Excellent"]
        return descriptions[moodIndex]
    }
} 