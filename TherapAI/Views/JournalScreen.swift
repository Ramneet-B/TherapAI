import SwiftUI

struct JournalScreen: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var newEntryText = ""
    @State private var showingNewEntry = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Journal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Express your thoughts and track your journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                // Journal Entries List
                if journalViewModel.journalEntries.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No journal entries yet")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Start writing your first entry to begin tracking your thoughts and experiences.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(journalViewModel.journalEntries) { entry in
                                JournalEntryCard(entry: entry)
                            }
                        }
                        .padding()
                    }
                }
                
                // Add Entry Button
                Button(action: {
                    showingNewEntry = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Entry")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(
                entryText: $newEntryText,
                onSave: saveNewEntry,
                onCancel: {
                    showingNewEntry = false
                    newEntryText = ""
                }
            )
        }
        .alert("Entry Saved!", isPresented: $showingSuccessAlert) {
            Button("OK") {}
        } message: {
            Text("Your journal entry has been saved successfully.")
        }
    }
    
    private func saveNewEntry() {
        guard !newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        addJournalEntry(content: newEntryText)
        newEntryText = ""
        showingNewEntry = false
        showingSuccessAlert = true
    }
    
    private func addJournalEntry(content: String) {
        let newEntry = JournalEntry(
            content: content,
            aiFeedback: generatePlaceholderFeedback(),
            createdAt: Date(),
            updatedAt: Date(),
            wordCount: wordCount(text: content)
        )
        
        journalViewModel.journalEntries.insert(newEntry, at: 0)
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

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date and time
            HStack {
                Text(entry.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(entry.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Entry content
            Text(entry.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // AI Feedback if available
            if let aiFeedback = entry.aiFeedback, !aiFeedback.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                        Text("AI Insights")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                    
                    Text(aiFeedback)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct NewJournalEntryView: View {
    @Binding var entryText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Writing area
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's on your mind?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Start writing...", text: $entryText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .lineLimit(5...)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    JournalScreen()
        .environmentObject(JournalViewModel())
} 