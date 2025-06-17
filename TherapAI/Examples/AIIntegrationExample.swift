import SwiftUI

/*
 This file demonstrates how to integrate OpenRouter AI into your TherapAI app.
 
 ## Setup Instructions:
 
 1. **Add your API key to Secrets.plist**:
    - Replace the placeholder key with your actual OpenRouter API key
    - Make sure Secrets.plist is not tracked by Git (already in .gitignore)
 
 2. **Update your project**:
    - Add the new service files to your Xcode project
    - Ensure all files are added to your target
 
 3. **Test the integration**:
    - Run the app and try sending a message in the chat
    - Check that rate limiting works by sending multiple messages
    - Verify error handling by temporarily using an invalid API key
 */

// MARK: - Example Usage in a SwiftUI View
struct AIIntegrationExampleView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var testPrompt = "I'm feeling anxious about work today"
    @State private var aiResponse = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Rate Limit Status
                RateLimitStatusCard()
                
                // Test AI Call
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test AI Integration")
                        .font(.headline)
                    
                    TextField("Enter a message", text: $testPrompt)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send to AI") {
                        testAICall()
                    }
                    .disabled(isLoading || testPrompt.isEmpty)
                    .buttonStyle(.borderedProminent)
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI is thinking...")
                                .font(.caption)
                        }
                    }
                    
                    if !aiResponse.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Response:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(aiResponse)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    if !errorMessage.isEmpty {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // Chat Integration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Full Chat Integration")
                        .font(.headline)
                    
                    NavigationLink("Open Chat with AI") {
                        ChatScreen()
                            .environmentObject(chatViewModel)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Integration Test")
        }
    }
    
    private func testAICall() {
        isLoading = true
        errorMessage = ""
        aiResponse = ""
        
        Task { @MainActor in
            do {
                let response = try await OpenRouterService.shared.fetchAIResponse(
                    prompt: testPrompt,
                    conversationHistory: []
                )
                
                aiResponse = response
                isLoading = false
                
            } catch let error as OpenRouterError {
                errorMessage = error.localizedDescription
                isLoading = false
            } catch {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

// MARK: - Rate Limit Status Card
struct RateLimitStatusCard: View {
    @StateObject private var rateLimiter = RateLimiter.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Rate Limit Status")
                    .font(.headline)
                
                Spacer()
                
                Button("Reset") {
                    Task { @MainActor in
                        rateLimiter.reset()
                    }
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
            
            let remaining = rateLimiter.remainingCalls()
            let message = rateLimiter.getRateLimitMessage()
            
            HStack {
                Circle()
                    .fill(remaining > 0 ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text("\(remaining) calls remaining")
                    .font(.subheadline)
            }
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let timeUntil = rateLimiter.timeUntilNextCall() {
                Text("Next call available in: \(Int(timeUntil))s")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Manual Service Usage Example
class ExampleAIUsage {
    
    // Example: Simple AI call
    func sendSimpleMessage() async {
        do {
            let response = try await OpenRouterService.shared.fetchAIResponse(
                prompt: "I'm feeling stressed about work deadlines"
            )
            print("AI Response: \(response)")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Example: AI call with conversation history
    func sendMessageWithContext(messages: [ChatMessage]) async {
        do {
            let response = try await OpenRouterService.shared.fetchAIResponse(
                prompt: "Can you help me understand these feelings better?",
                conversationHistory: messages
            )
            print("AI Response: \(response)")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Example: Check rate limits before calling
    func safeAICall() async {
        let rateLimiter = await RateLimiter.shared
        
        let canCall = await rateLimiter.canMakeCall()
        guard canCall else {
            let message = await rateLimiter.getRateLimitMessage()
            print("Rate limit exceeded: \(message)")
            return
        }
        
        do {
            let response = try await OpenRouterService.shared.fetchAIResponse(
                prompt: "How can I manage anxiety better?"
            )
            print("AI Response: \(response)")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AIIntegrationExampleView()
} 