import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let createdAt: Date
    let lastLoginAt: Date?
    let subscriptionStatus: SubscriptionStatus
    let trialStartDate: Date
    let subscriptionEndDate: Date?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var isTrialActive: Bool {
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: trialStartDate) ?? Date()
        return Date() < trialEndDate && subscriptionStatus == .trial
    }
    
    var trialDaysRemaining: Int {
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: trialStartDate) ?? Date()
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: trialEndDate).day ?? 0
        return max(0, daysRemaining)
    }
    
    var hasActiveAccess: Bool {
        switch subscriptionStatus {
        case .trial:
            return isTrialActive
        case .active:
            guard let endDate = subscriptionEndDate else { return false }
            return Date() < endDate
        case .expired, .cancelled:
            return false
        }
    }
    
    init(id: String = UUID().uuidString, email: String, firstName: String, lastName: String) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
        self.lastLoginAt = nil
        self.subscriptionStatus = .trial
        self.trialStartDate = Date()
        self.subscriptionEndDate = nil
    }
    
    // Initialize with subscription data
    init(id: String, email: String, firstName: String, lastName: String, 
         createdAt: Date, lastLoginAt: Date?, subscriptionStatus: SubscriptionStatus, 
         trialStartDate: Date, subscriptionEndDate: Date?) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.subscriptionStatus = subscriptionStatus
        self.trialStartDate = trialStartDate
        self.subscriptionEndDate = subscriptionEndDate
    }
}

enum SubscriptionStatus: String, Codable, CaseIterable {
    case trial = "trial"
    case active = "active"
    case expired = "expired"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .trial:
            return "Free Trial"
        case .active:
            return "Active"
        case .expired:
            return "Expired"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .trial:
            return "blue"
        case .active:
            return "green"
        case .expired, .cancelled:
            return "red"
        }
    }
}

enum SubscriptionPlan: String, Codable, CaseIterable {
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
    
    var price: Double {
        switch self {
        case .monthly:
            return 9.99
        case .yearly:
            return 79.99
        }
    }
    
    var priceString: String {
        return String(format: "$%.2f", price)
    }
    
    var monthlyEquivalent: String {
        switch self {
        case .monthly:
            return "$9.99/month"
        case .yearly:
            return "$6.67/month"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly:
            return nil
        case .yearly:
            return "Save 33%"
        }
    }
    
    var description: String {
        switch self {
        case .monthly:
            return "Full access to TherapAI with monthly billing"
        case .yearly:
            return "Full access to TherapAI with yearly billing - best value!"
        }
    }
}

struct Subscription: Codable {
    let id: String
    let userId: String
    let plan: SubscriptionPlan
    let status: SubscriptionStatus
    let startDate: Date
    let endDate: Date
    let autoRenew: Bool
    
    init(userId: String, plan: SubscriptionPlan) {
        self.id = UUID().uuidString
        self.userId = userId
        self.plan = plan
        self.status = .active
        self.startDate = Date()
        self.autoRenew = true
        
        // Calculate end date based on plan
        switch plan {
        case .monthly:
            self.endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        case .yearly:
            self.endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        }
    }
}

enum AuthState {
    case signedOut
    case signedIn(User)
    case loading
    case error(String)
    
    var isSignedIn: Bool {
        if case .signedIn = self {
            return true
        }
        return false
    }
    
    var user: User? {
        if case .signedIn(let user) = self {
            return user
        }
        return nil
    }
}