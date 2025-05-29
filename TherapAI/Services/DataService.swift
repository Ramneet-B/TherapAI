import Foundation
import SwiftUI

@MainActor
class DataService: ObservableObject {
    lazy var moodViewModel: MoodViewModel = {
        MoodViewModel()
    }()
    
    lazy var journalViewModel: JournalViewModel = {
        JournalViewModel()
    }()
    
    lazy var chatViewModel: ChatViewModel = {
        ChatViewModel()
    }()
    
    static let shared = DataService()
    
    private init() {}
    
    // MARK: - Analytics & Insights
    
    func getWeeklyMoodSummary() -> [String: Int] {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let entries = moodViewModel.moodEntries.filter { $0.date >= oneWeekAgo }
        var moodCounts: [String: Int] = [:]
        
        for entry in entries {
            let moodDescription = entry.moodDescription
            moodCounts[moodDescription, default: 0] += 1
        }
        
        return moodCounts
    }
    
    func getTotalJournalEntries() -> Int {
        return journalViewModel.journalEntries.count
    }
    
    func getTotalChatMessages() -> Int {
        return chatViewModel.messages.count
    }
    
    // MARK: - Data Management
    
    func exportUserData() -> [String: Any] {
        var exportData: [String: Any] = [:]
        
        // Export mood entries
        exportData["moodEntries"] = moodViewModel.moodEntries.map { entry in
            [
                "date": entry.date,
                "mood": entry.moodEmoji,
                "note": entry.note ?? ""
            ]
        }
        
        // Export journal entries
        exportData["journalEntries"] = journalViewModel.journalEntries.map { entry in
            [
                "date": entry.createdAt,
                "content": entry.content,
                "wordCount": entry.wordCount
            ]
        }
        
        return exportData
    }
    
    func clearAllData() {
        moodViewModel.moodEntries.removeAll()
        journalViewModel.journalEntries.removeAll()
        chatViewModel.messages.removeAll()
        chatViewModel.addInitialGreeting()
    }
} 