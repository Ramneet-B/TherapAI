import SwiftUI

struct SignupScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Navigation Bar
                    CustomNavigationBar(isShowingSignUp: $isShowingSignUp)
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: 25) {
                            // Header
                            HeaderSection()
                                .padding(.top, 20)
                            
                            // Form
                            SignUpFormSection(authViewModel: authViewModel)
                                .padding(.horizontal, 20)
                            
                            Spacer(minLength: 50)
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
}

// MARK: - Custom Navigation Bar
struct CustomNavigationBar: View {
    @Binding var isShowingSignUp: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                print("🚫 Cancel button tapped")
                dismissKeyboard()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingSignUp = false
                }
                print("🚫 isShowingSignUp set to: \(isShowingSignUp)")
            }) {
                Text("Cancel")
                    .foregroundColor(.purple)
                    .font(.body)
            }
            
            Spacer()
            
            Text("Sign Up")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Invisible button for balance
            Button("") { }
                .opacity(0)
                .disabled(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Join TherapAI and start your wellness journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - SignUp Form Section
struct SignUpFormSection: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            // Name Fields
            HStack(spacing: 15) {
                AuthTextField(
                    title: "First Name",
                    placeholder: "First name",
                    text: $authViewModel.firstName
                )
                
                AuthTextField(
                    title: "Last Name",
                    placeholder: "Last name",
                    text: $authViewModel.lastName
                )
            }
            
            // Email Field
            AuthTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: $authViewModel.email,
                keyboardType: .emailAddress
            )
            
            // Password Fields
            VStack(spacing: 20) {
                AuthSecureField(
                    title: "Password",
                    placeholder: "Create a password",
                    text: $authViewModel.password
                )
                
                AuthSecureField(
                    title: "Confirm Password",
                    placeholder: "Confirm your password",
                    text: $authViewModel.confirmPassword
                )
            }
            
            // Password Requirements
            PasswordRequirementsView(password: authViewModel.password)
            
            // Error Message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Sign Up Button
            AuthButton(
                title: "Create Account",
                isLoading: authViewModel.isLoading,
                isEnabled: authViewModel.isSignUpFormValid,
                action: {
                    dismissKeyboard()
                    Task {
                        await authViewModel.signUp()
                    }
                }
            )
        }
    }
}

// MARK: - Password Requirements View
struct PasswordRequirementsView: View {
    let password: String
    
    private var requirements: [(String, Bool)] {
        [
            ("At least 8 characters", password.count >= 8),
            ("One uppercase letter", password.range(of: "[A-Z]", options: .regularExpression) != nil),
            ("One number", password.range(of: "[0-9]", options: .regularExpression) != nil),
            ("One special character", password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password Requirements:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(requirements.indices, id: \.self) { index in
                    HStack(spacing: 8) {
                        Image(systemName: requirements[index].1 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(requirements[index].1 ? .green : .gray)
                            .font(.caption)
                        
                        Text(requirements[index].0)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SignupScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignupScreen(authViewModel: AuthViewModel(), isShowingSignUp: .constant(true))
    }
}