import SwiftUI

struct JournalScreen: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    var body: some View {
        ZStack {
            Color(.systemPurple).opacity(0.07).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                Text("Journal")
                    .font(.largeTitle).bold()
                    .foregroundColor(.black)
                    .padding(.top, 24)
                
                TextEditor(text: $journalViewModel.journalText)
                    .frame(height: 140)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.purple.opacity(0.08), radius: 8, x: 0, y: 4)
                    .overlay(
                        Group {
                            if journalViewModel.journalText.isEmpty {
                                Text("Write about your day...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }, alignment: .topLeading
                    )
                
                Button(action: { journalViewModel.submitJournalEntry() }) {
                    if journalViewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Submit")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(journalViewModel.journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.purple)
                .cornerRadius(16)
                .shadow(color: Color.purple.opacity(0.15), radius: 6, x: 0, y: 3)
                .disabled(journalViewModel.journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || journalViewModel.isSubmitting)
                
                if !journalViewModel.aiFeedback.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Feedback")
                            .font(.subheadline).bold()
                            .foregroundColor(.gray)
                        Text(journalViewModel.aiFeedback)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.08))
                    .cornerRadius(18)
                    .shadow(color: Color.purple.opacity(0.06), radius: 6, x: 0, y: 2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .alert("Journal Saved!", isPresented: $journalViewModel.showingSuccess) {
            Button("OK") { }
        }
    }
}

struct JournalScreen_Previews: PreviewProvider {
    static var previews: some View {
        JournalScreen()
            .environmentObject(JournalViewModel())
    }
} 