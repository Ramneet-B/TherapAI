import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var currentConversationId: UUID = UUID()
    
    init() {
        loadMessages()
        
        // If no conversation exists, create initial AI greeting
        if messages.isEmpty {
            addInitialGreeting()
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = inputText
        inputText = ""
        
        // Save user message
        let userChatMessage = ChatMessage(
            content: userMessage,
            isFromUser: true,
            timestamp: Date(),
            conversationId: currentConversationId
        )
        
        messages.append(userChatMessage)
        isLoading = true
        
        // Simulate AI response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.generateAIResponse(to: userMessage)
        }
    }
    
    private func generateAIResponse(to userMessage: String) {
        let aiResponse = generatePlaceholderResponse(for: userMessage)
        
        let aiChatMessage = ChatMessage(
            content: aiResponse,
            isFromUser: false,
            timestamp: Date(),
            conversationId: currentConversationId
        )
        
        messages.append(aiChatMessage)
        isLoading = false
    }
    
    func loadMessages() {
        // For now, keep existing messages in memory
        // This will be replaced with Core Data when entities are configured
    }
    
    func startNewConversation() {
        currentConversationId = UUID()
        messages.removeAll()
        addInitialGreeting()
    }
    
    func deleteMessage(_ message: ChatMessage) {
        messages.removeAll { $0.id == message.id }
    }
    
    func clearConversation() {
        messages.removeAll()
        addInitialGreeting()
    }
    
    func addInitialGreeting() {
        let greeting = ChatMessage(
            content: "Hello! I'm here to listen and support you. Feel free to share what's on your mind today.",
            isFromUser: false,
            timestamp: Date(),
            conversationId: currentConversationId
        )
        
        messages.append(greeting)
    }
    
    private func generatePlaceholderResponse(for userMessage: String) -> String {
        let message = userMessage.lowercased()
        
        if message.contains("stress") || message.contains("anxiety") {
            return "I understand that you're feeling stressed. It's completely normal to experience stress, and it's important to acknowledge these feelings. What specific situations or thoughts are contributing to your stress right now?"
        } else if message.contains("sad") || message.contains("depressed") {
            return "Thank you for sharing how you're feeling. Sadness is a natural emotion, and it's okay to feel this way. Would you like to talk about what might be contributing to these feelings?"
        } else if message.contains("happy") || message.contains("good") || message.contains("great") {
            return "I'm so glad to hear that you're feeling positive! It's wonderful when we can recognize and appreciate good moments. What's been going well for you?"
        } else if message.contains("tired") || message.contains("exhausted") {
            return "Feeling tired can really impact our overall wellbeing. Are you getting enough rest, or is this more of an emotional exhaustion? Let's explore what might be draining your energy."
        } else {
            let responses = [
                "I hear what you're saying. Can you tell me more about that?",
                "That sounds important to you. How does that make you feel?",
                "Thank you for sharing that with me. What thoughts come up when you think about this?",
                "I'm here to listen. What would be most helpful for you to explore right now?",
                "It takes courage to share your thoughts. How long have you been feeling this way?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
} 