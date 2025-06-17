import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    
    private let authService = AuthService.shared
    
    init() {
        checkAuthStatus()
    }
    
    // MARK: - Auth Status
    
    func checkAuthStatus() {
        if let user = authService.getCurrentUser(), authService.isSignedIn() {
            print("✅ Found existing user: \(user.email)")
            authState = .signedIn(user)
        } else {
            print("📝 No existing user found, showing sign-in")
            authState = .signedOut
        }
    }
    
    // MARK: - Sign In
    
    func signIn() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await authService.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), 
                                            password: password)
        
        await MainActor.run {
            switch result {
            case .success(let user):
                print("✅ SignIn Success: \(user.email)")
                authState = .signedIn(user)
                clearForm()
            case .failure(let error):
                print("❌ SignIn Error: \(error.localizedDescription)")
                authState = .error(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Sign Up
    
    func signUp() async {
        guard validateSignUpForm() else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await authService.signUp(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        await MainActor.run {
            switch result {
            case .success(let user):
                print("✅ SignUp Success: \(user.email)")
                authState = .signedIn(user)
                clearForm()
            case .failure(let error):
                print("❌ SignUp Error: \(error.localizedDescription)")
                authState = .error(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        if authService.signOut() {
            authState = .signedOut
            clearForm()
        }
    }
    
    // MARK: - Form Validation
    
    private func validateSignUpForm() -> Bool {
        // Check if passwords match
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        
        // Check if all fields are filled
        if email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        return true
    }
    
    var isSignInFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    var isSignUpFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && 
        !firstName.isEmpty && !lastName.isEmpty && password == confirmPassword
    }
    
    // MARK: - Helper Methods
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}