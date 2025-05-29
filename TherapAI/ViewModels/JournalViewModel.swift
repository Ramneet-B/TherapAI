import Foundation
import SwiftUI

@MainActor
class JournalViewModel: ObservableObject {
    @Published var journalText: String = ""
    @Published var aiFeedback: String = ""
    @Published var journalEntries: [JournalEntry] = []
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showingSuccess: Bool = false
    
    init() {
        loadJournalEntries()
    }
    
    func submitJournalEntry() {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSubmitting = true
        
        let newEntry = JournalEntry(
            content: journalText,
            aiFeedback: generatePlaceholderFeedback(),
            createdAt: Date(),
            updatedAt: Date(),
            wordCount: wordCount(text: journalText)
        )
        
        journalEntries.insert(newEntry, at: 0)
        
        // Set the AI feedback for display
        aiFeedback = newEntry.aiFeedback ?? ""
        
        // Reset form
        journalText = ""
        showingSuccess = true
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingSuccess = false
        }
        
        isSubmitting = false
    }
    
    func loadJournalEntries() {
        // For now, keep existing entries in memory
        // This will be replaced with Core Data when entities are configured
        
        // Load the latest feedback if available
        if let latestEntry = journalEntries.first {
            aiFeedback = latestEntry.aiFeedback ?? ""
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
    }
    
    func getEntriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return journalEntries.filter { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: date)
        }
    }
    
    func getTotalWordCount() -> Int {
        return journalEntries.reduce(0) { total, entry in
            total + entry.wordCount
        }
    }
    
    private func wordCount(text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private func generatePlaceholderFeedback() -> String {
        let responses = [
            "Thank you for sharing your thoughts. It's important to express your feelings and reflect on your experiences.",
            "I appreciate your openness. Writing can be a powerful tool for self-reflection and emotional processing.",
            "Your willingness to explore your thoughts shows great self-awareness. Keep up this positive practice.",
            "It's wonderful that you're taking time to journal. This practice can help you better understand your emotions and experiences.",
            "Thank you for trusting this space with your thoughts. Regular journaling can be very beneficial for mental health."
        ]
        return responses.randomElement() ?? responses[0]
    }
} 