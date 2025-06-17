import Foundation
import CryptoKit

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let keychainService = KeychainService.shared
    
    // Mock user database - In production, this would be a real backend
    private var userDatabase: [String: StoredUserCredentials] = [:]
    
    private init() {
        loadMockUsers()
    }
    
    struct StoredUserCredentials {
        let user: User
        let hashedPassword: String
        let salt: Data
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async -> Result<User, AuthError> {
        // Validate input
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        
        guard isValidPassword(password) else {
            return .failure(.weakPassword)
        }
        
        // Check if user already exists
        if userDatabase[email] != nil {
            return .failure(.userAlreadyExists)
        }
        
        // Create new user
        let user = User(email: email, firstName: firstName, lastName: lastName)
        
        // Hash password with salt
        let salt = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let hashedPassword = hashPassword(password, salt: salt)
        
        // Store in mock database
        userDatabase[email] = StoredUserCredentials(
            user: user,
            hashedPassword: hashedPassword,
            salt: salt
        )
        
        // Generate and store auth token
        let token = generateAuthToken(for: user)
        guard saveAuthToken(token, for: user) else {
            return .failure(.unknown("Failed to save authentication token"))
        }
        
        return .success(user)
    }
    
    func signIn(email: String, password: String) async -> Result<User, AuthError> {
        // Find user in database
        guard let storedCredentials = userDatabase[email] else {
            return .failure(.userNotFound)
        }
        
        // Verify password
        let hashedPassword = hashPassword(password, salt: storedCredentials.salt)
        guard hashedPassword == storedCredentials.hashedPassword else {
            return .failure(.incorrectPassword)
        }
        
        // Update last login
        var updatedUser = storedCredentials.user
        updatedUser = User(
            id: updatedUser.id,
            email: updatedUser.email,
            firstName: updatedUser.firstName,
            lastName: updatedUser.lastName
        )
        
        // Generate and store auth token
        let token = generateAuthToken(for: updatedUser)
        guard saveAuthToken(token, for: updatedUser) else {
            return .failure(.unknown("Failed to save authentication token"))
        }
        
        return .success(updatedUser)
    }
    
    func signOut() -> Bool {
        keychainService.clearAll()
        return true
    }
    
    func getCurrentUser() -> User? {
        return keychainService.load(User.self, for: .userData)
    }
    
    func isSignedIn() -> Bool {
        return getCurrentUser() != nil && keychainService.loadString(for: .authToken) != nil
    }
    
    // MARK: - Password Management
    
    private func hashPassword(_ password: String, salt: Data) -> String {
        let passwordData = Data(password.utf8)
        let combinedData = passwordData + salt
        let hashedData = SHA256.hash(data: combinedData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func generateAuthToken(for user: User) -> String {
        let tokenData = "\(user.id):\(Date().timeIntervalSince1970):\(UUID().uuidString)"
        return Data(tokenData.utf8).base64EncodedString()
    }
    
    private func saveAuthToken(_ token: String, for user: User) -> Bool {
        let tokenSaved = keychainService.save(string: token, for: .authToken)
        let userSaved = keychainService.save(user, for: .userData)
        let emailSaved = keychainService.save(string: user.email, for: .userEmail)
        let idSaved = keychainService.save(string: user.id, for: .userID)
        
        return tokenSaved && userSaved && emailSaved && idSaved
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, one uppercase, one number, one special character
        let minLength = password.count >= 8
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        return minLength && hasUppercase && hasNumber && hasSpecialChar
    }
    
    // MARK: - Mock Data (Remove in production)
    
    private func loadMockUsers() {
        // Create a demo user for testing
        let demoUser = User(email: "demo@therapai.com", firstName: "Demo", lastName: "User")
        let salt = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let hashedPassword = hashPassword("Demo123!", salt: salt)
        
        userDatabase["demo@therapai.com"] = StoredUserCredentials(
            user: demoUser,
            hashedPassword: hashedPassword,
            salt: salt
        )
    }
}

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case userAlreadyExists
    case userNotFound
    case incorrectPassword
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters with uppercase, number, and special character"
        case .userAlreadyExists:
            return "An account with this email already exists"
        case .userNotFound:
            return "No account found with this email"
        case .incorrectPassword:
            return "Incorrect password"
        case .networkError:
            return "Network connection error"
        case .unknown(let message):
            return message
        }
    }
}