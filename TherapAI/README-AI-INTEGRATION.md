# TherapAI - OpenRouter AI Integration

This document outlines the secure integration of OpenRouter's AI API into the TherapAI mental health app.

## 🔐 Security Overview

### API Key Management
- **✅ Secure**: API key stored in `Secrets.plist` (not tracked by Git)
- **✅ Protected**: `.gitignore` prevents accidental commits
- **✅ Runtime Loading**: Key loaded securely at runtime from bundle

### Rate Limiting
- **5 API calls per hour** to control costs and prevent abuse
- In-memory tracking with automatic cleanup
- User-friendly messages about remaining calls
- Graceful handling when limits are exceeded

## 📁 File Structure

```
TherapAI/
├── Services/
│   ├── OpenRouterService.swift     # Main AI service
│   └── RateLimiter.swift          # Rate limiting logic
├── ViewModels/
│   └── ChatViewModel.swift        # Updated with AI integration
├── Views/
│   └── ChatScreen.swift          # Enhanced chat UI
├── Examples/
│   └── AIIntegrationExample.swift # Usage examples
├── Secrets.plist                 # API credentials (⚠️ NOT in Git)
├── .gitignore                    # Updated to exclude secrets
└── README-AI-INTEGRATION.md     # This file
```

## 🚀 Setup Instructions

### 1. Configure API Key

1. Replace the placeholder in `Secrets.plist` with your actual OpenRouter API key:
```xml
<key>OpenRouterAPIKey</key>
<string>sk-or-v1-YOUR_ACTUAL_API_KEY_HERE</string>
```

2. Verify your API key format:
   - Starts with `sk-or-v1-`
   - Contains your actual OpenRouter API key
   - No extra spaces or characters

### 2. Add Files to Xcode Project

1. Add all new files to your Xcode project
2. Ensure they're added to your app target
3. Verify the project builds successfully

### 3. Test Integration

1. Run the app and navigate to the Chat screen
2. Send a test message
3. Verify you see "AI is thinking..." animation
4. Check that real AI responses appear

## 🔧 Configuration Options

### Rate Limiting
Modify rate limits in `RateLimiter.swift`:
```swift
private let maxCallsPerHour = 5     // Increase if needed
private let timeWindow: TimeInterval = 3600  // 1 hour
```

### AI Model Settings
Customize AI behavior in `OpenRouterService.swift`:
```swift
private let model = "openai/gpt-3.5-turbo"  // Change model
temperature: 0.7,        // Creativity (0.0-1.0)
maxTokens: 300          // Response length
```

### Therapeutic Context
The system prompt can be customized in `createRequest()`:
```swift
// Add system message for therapeutic context
messages.append(OpenRouterMessage(
    role: "system",
    content: """
    You are a compassionate AI therapist assistant...
    """
))
```

## 📱 Usage Examples

### Basic AI Call
```swift
let response = try await OpenRouterService.shared.fetchAIResponse(
    prompt: "I'm feeling anxious today"
)
```

### With Conversation History
```swift
let response = try await OpenRouterService.shared.fetchAIResponse(
    prompt: "Can you help me understand this better?",
    conversationHistory: previousMessages
)
```

### Check Rate Limits
```swift
let rateLimiter = RateLimiter.shared
if rateLimiter.canMakeCall() {
    // Make AI call
} else {
    // Show rate limit message
    let message = rateLimiter.getRateLimitMessage()
}
```

## ⚠️ Security Best Practices

### 1. API Key Protection
- **NEVER** commit `Secrets.plist` to version control
- **NEVER** hardcode API keys in source code
- **ALWAYS** use environment-specific configurations
- **REGULARLY** rotate API keys

### 2. Error Handling
- Don't expose internal error details to users
- Log errors securely for debugging
- Provide friendly fallback messages
- Handle network timeouts gracefully

### 3. Input Validation
- Sanitize user input before sending to AI
- Implement content filtering if needed
- Validate response format and length
- Handle malformed API responses

### 4. Production Considerations
- Use different API keys for development/production
- Implement server-side rate limiting for production
- Monitor API usage and costs
- Set up alerts for unusual activity

## 🛠 Error Handling

The system handles various error types:

| Error Type | Description | User Message |
|------------|-------------|--------------|
| `noAPIKey` | Missing/invalid API key | "API key not found" |
| `rateLimitExceeded` | Too many calls | "Rate limit reached. Try again in Xm Xs" |
| `networkError` | Connection issues | "Network error: [details]" |
| `apiError` | OpenRouter API errors | "AI service error: [details]" |
| `decodingError` | Response parsing | "Response parsing error" |

## 🔍 Testing

### Rate Limit Testing
```swift
// Reset rate limiter for testing
RateLimiter.shared.reset()

// Test limit enforcement
for i in 1...6 {
    let canCall = RateLimiter.shared.canMakeCall()
    print("Call \(i): \(canCall ? "Allowed" : "Blocked")")
    if canCall {
        RateLimiter.shared.recordCall()
    }
}
```

### Error Simulation
```swift
// Test with invalid API key
// Temporarily modify Secrets.plist with invalid key
// Verify error handling works correctly
```

## 📊 Monitoring

### What to Monitor
- API call frequency and patterns
- Response times and success rates
- Error rates and types
- User feedback on AI responses
- Costs and usage limits

### Metrics to Track
- Calls per hour/day
- Average response time
- Error percentage
- User satisfaction
- Token usage and costs

## 🚀 Future Enhancements

### Planned Features
- **Conversation Memory**: Persistent conversation context
- **Mood-Aware Responses**: Integrate with mood tracking data
- **Custom Prompts**: Specialized prompts for different therapy types
- **Response Caching**: Cache common responses to reduce API calls
- **Analytics**: Track conversation effectiveness

### Advanced Security
- **End-to-End Encryption**: Encrypt messages before API calls
- **User Consent**: Explicit consent for AI processing
- **Data Retention**: Configurable data retention policies
- **Audit Logging**: Comprehensive audit trails

---

## 🆘 Troubleshooting

### Common Issues

1. **"API key not found"**
   - Verify `Secrets.plist` exists and is added to the Xcode project
   - Check the API key format and spelling
   - Ensure the file is included in your app bundle

2. **"Rate limit exceeded"**
   - Wait for the time window to reset
   - Use `RateLimiter.shared.reset()` for testing only
   - Consider increasing limits for production

3. **Network errors**
   - Check internet connectivity
   - Verify OpenRouter service status
   - Test with a simple curl command

4. **No AI responses**
   - Check Xcode console for error messages
   - Verify the API key has sufficient credits
   - Test the integration example file

### Debug Mode
Enable detailed logging by adding breakpoints in:
- `OpenRouterService.fetchAIResponse()`
- `ChatViewModel.generateAIResponse()`
- Error handling blocks

---

**Ready to transform mental health care with AI! 🧠✨** 