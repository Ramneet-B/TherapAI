import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let createdAt: Date
    let lastLoginAt: Date?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: String = UUID().uuidString, email: String, firstName: String, lastName: String) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
        self.lastLoginAt = nil
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