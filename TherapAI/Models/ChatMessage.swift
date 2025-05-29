import Foundation

// Temporary struct-based model until Core Data entities are configured
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var conversationId: UUID?
    
    // Computed properties
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var senderName: String {
        return isFromUser ? "You" : "AI Therapist"
    }
} 