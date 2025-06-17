import Foundation

@MainActor
class RateLimiter: ObservableObject {
    private var callTimes: [Date] = []
    private let maxCallsPerHour = 5
    private let timeWindow: TimeInterval = 3600 // 1 hour in seconds
    
    static let shared = RateLimiter()
    
    private init() {}
    
    /// Check if a new API call is allowed based on rate limits
    /// - Returns: True if call is allowed, false if rate limit exceeded
    func canMakeCall() -> Bool {
        cleanOldCalls()
        return callTimes.count < maxCallsPerHour
    }
    
    /// Record a new API call timestamp
    func recordCall() {
        cleanOldCalls()
        callTimes.append(Date())
    }
    
    /// Get remaining calls in current time window
    func remainingCalls() -> Int {
        cleanOldCalls()
        return max(0, maxCallsPerHour - callTimes.count)
    }
    
    /// Get time until next call is allowed (in seconds)
    func timeUntilNextCall() -> TimeInterval? {
        cleanOldCalls()
        
        guard callTimes.count >= maxCallsPerHour else {
            return nil // Calls are allowed immediately
        }
        
        // Find the oldest call in the current window
        guard let oldestCall = callTimes.first else {
            return nil
        }
        
        let resetTime = oldestCall.addingTimeInterval(timeWindow)
        return max(0, resetTime.timeIntervalSinceNow)
    }
    
    /// Remove calls older than the time window
    private func cleanOldCalls() {
        let cutoffTime = Date().addingTimeInterval(-timeWindow)
        callTimes.removeAll { $0 < cutoffTime }
    }
    
    /// Reset all rate limiting (useful for testing or admin override)
    func reset() {
        callTimes.removeAll()
    }
    
    /// Get a user-friendly message about rate limit status
    func getRateLimitMessage() -> String {
        let remaining = remainingCalls()
        
        if remaining > 0 {
            return "You have \(remaining) AI message\(remaining == 1 ? "" : "s") remaining this hour."
        } else {
            if let timeUntil = timeUntilNextCall() {
                let minutes = Int(timeUntil / 60)
                let seconds = Int(timeUntil.truncatingRemainder(dividingBy: 60))
                
                if minutes > 0 {
                    return "Rate limit reached. Try again in \(minutes)m \(seconds)s."
                } else {
                    return "Rate limit reached. Try again in \(seconds) seconds."
                }
            }
            return "Rate limit reached. Please try again later."
        }
    }
} 