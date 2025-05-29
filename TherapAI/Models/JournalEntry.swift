import Foundation

// Temporary struct-based model until Core Data entities are configured
struct JournalEntry: Identifiable, Codable {
    let id = UUID()
    var content: String
    var aiFeedback: String?
    var createdAt: Date
    var updatedAt: Date
    var wordCount: Int
    
    // Computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var preview: String {
        let maxLength = 100
        if content.count <= maxLength {
            return content
        }
        let index = content.index(content.startIndex, offsetBy: maxLength)
        return String(content[..<index]) + "..."
    }
} 