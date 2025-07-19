import Foundation

// MARK: - OpenRouter API Models
struct OpenRouterRequest: Codable {
    let model: String
    let messages: [OpenRouterMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenRouterMessage: Codable {
    let role: String
    let content: String
}

struct OpenRouterResponse: Codable {
    let choices: [OpenRouterChoice]
    let usage: OpenRouterUsage?
}

struct OpenRouterChoice: Codable {
    let message: OpenRouterMessage
}

struct OpenRouterUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - OpenRouter Service Errors
enum OpenRouterError: LocalizedError {
    case noAPIKey
    case invalidURL
    case rateLimitExceeded(message: String)
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not found. Please check your configuration."
        case .invalidURL:
            return "Invalid API endpoint URL."
        case .rateLimitExceeded(let message):
            return message
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI service."
        case .apiError(let message):
            return "AI service error: \(message)"
        case .decodingError(let error):
            return "Response parsing error: \(error.localizedDescription)"
        }
    }
}

// MARK: - OpenRouter Service
@MainActor
class OpenRouterService: ObservableObject {
    private let baseURL = "https://openrouter.ai/api/v1"
    private let model = "openai/gpt-3.5-turbo"
    private let rateLimiter = RateLimiter.shared
    
    static let shared = OpenRouterService()
    
    private init() {}
    
    /// Fetch AI response for a therapeutic conversation
    /// - Parameters:
    ///   - prompt: User's message
    ///   - conversationHistory: Previous messages for context (optional)
    /// - Returns: AI response string
    func fetchAIResponse(
        prompt: String,
        conversationHistory: [ChatMessage] = []
    ) async throws -> String {
        
        // Check rate limiting
        guard rateLimiter.canMakeCall() else {
            let message = rateLimiter.getRateLimitMessage()
            throw OpenRouterError.rateLimitExceeded(message: message)
        }
        
        // Load API credentials
        let (apiKey, referer) = try loadCredentials()
        
        // Prepare the request
        let request = try createRequest(
            prompt: prompt,
            conversationHistory: conversationHistory,
            apiKey: apiKey,
            referer: referer
        )
        
        // Make the API call
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenRouterError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw OpenRouterError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }
            
            // Parse response
            let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
            
            guard let choice = openRouterResponse.choices.first else {
                throw OpenRouterError.invalidResponse
            }
            
            // Record successful call for rate limiting
            rateLimiter.recordCall()
            
            return choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as DecodingError {
            throw OpenRouterError.decodingError(error)
        } catch let error as OpenRouterError {
            throw error
        } catch {
            throw OpenRouterError.networkError(error)
        }
    }
    
    /// Load API credentials from Secrets.plist
    private func loadCredentials() throws -> (apiKey: String, referer: String) {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) else {
            throw OpenRouterError.noAPIKey
        }
        
        guard let apiKey = plist["OpenRouterAPIKey"] as? String,
              let referer = plist["AppReferer"] as? String,
              !apiKey.isEmpty else {
            throw OpenRouterError.noAPIKey
        }
        
        return (apiKey, referer)
    }
    
    /// Create URLRequest with proper headers and body
    private func createRequest(
        prompt: String,
        conversationHistory: [ChatMessage],
        apiKey: String,
        referer: String
    ) throws -> URLRequest {
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw OpenRouterError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(referer, forHTTPHeaderField: "HTTP-Referer")
        
        // Prepare messages with context
        var messages: [OpenRouterMessage] = []
        
        // Add system message for therapeutic context
        messages.append(OpenRouterMessage(
            role: "system",
            content: """
            You are a compassionate AI therapist assistant. IMPORTANT SAFETY GUIDELINES:
            
            CRISIS SITUATIONS: If someone mentions suicide, self-harm, or emergency situations, immediately respond with:
            "I'm concerned about what you're sharing. Please reach out for immediate help: Call 988 (Suicide & Crisis Lifeline) or 911 for emergencies. You deserve support from qualified professionals who can help you through this."
            
            YOUR ROLE:
            - Listen empathetically and provide supportive responses
            - Ask thoughtful follow-up questions to help users explore their feelings
            - Offer gentle guidance and evidence-based coping strategies
            - Maintain professional boundaries while being warm and understanding
            - NEVER provide medical diagnoses, prescribe medications, or replace professional therapy
            - Keep responses concise but meaningful (2-3 sentences typically)
            - Always encourage users to seek professional help for ongoing mental health concerns
            - Remind users that you are an AI assistant, not a licensed therapist
            
            Remember: You are a supportive tool, not a replacement for professional mental healthcare.
            """
        ))
        
        // Add recent conversation history (last 6 messages for context)
        let recentHistory = Array(conversationHistory.suffix(6))
        for message in recentHistory {
            messages.append(OpenRouterMessage(
                role: message.isFromUser ? "user" : "assistant",
                content: message.content
            ))
        }
        
        // Add current user message
        messages.append(OpenRouterMessage(role: "user", content: prompt))
        
        // Create request body
        let requestBody = OpenRouterRequest(
            model: model,
            messages: messages,
            temperature: 0.7, // Balanced creativity for therapeutic responses
            maxTokens: 300    // Keep responses concise
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        return request
    }
    
    /// Get current rate limit status for UI display
    func getRateLimitStatus() -> (remaining: Int, message: String) {
        let remaining = rateLimiter.remainingCalls()
        let message = rateLimiter.getRateLimitMessage()
        return (remaining, message)
    }
} 