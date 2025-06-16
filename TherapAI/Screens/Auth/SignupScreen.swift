import SwiftUI

struct SignupScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case firstName, lastName, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                        
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Join TherapAI and start your wellness journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Sign Up Form
                    VStack(spacing: 20) {
                        // Name Fields
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("First Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("First name", text: $authViewModel.firstName)
                                    .focused($focusedField, equals: .firstName)
                                    .textContentType(.givenName)
                                    .autocapitalization(.words)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Last Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Last name", text: $authViewModel.lastName)
                                    .focused($focusedField, equals: .lastName)
                                    .textContentType(.familyName)
                                    .autocapitalization(.words)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter your email", text: $authViewModel.email)
                                .focused($focusedField, equals: .email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            SecureTextField(title: "Create a password", text: $authViewModel.password)
                                .focused($focusedField, equals: .password)
                                .textContentType(.newPassword)
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            SecureTextField(title: "Confirm your password", text: $authViewModel.confirmPassword)
                                .focused($focusedField, equals: .confirmPassword)
                                .textContentType(.newPassword)
                        }
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Password Requirements:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Image(systemName: passwordLengthValid ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(passwordLengthValid ? .green : .secondary)
                                    Text("At least 8 characters")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: passwordHasUppercase ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(passwordHasUppercase ? .green : .secondary)
                                    Text("One uppercase letter")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: passwordHasNumber ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(passwordHasNumber ? .green : .secondary)
                                    Text("One number")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: passwordHasSpecialChar ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(passwordHasSpecialChar ? .green : .secondary)
                                    Text("One special character")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Sign Up Button
                        LoadingButton(
                            title: "Create Account",
                            isLoading: authViewModel.isLoading
                        ) {
                            Task {
                                await authViewModel.signUp()
                            }
                        }
                        .disabled(!authViewModel.isSignUpFormValid)
                        .opacity(authViewModel.isSignUpFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isShowingSignUp = false
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .onSubmit {
            switch focusedField {
            case .firstName:
                focusedField = .lastName
            case .lastName:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                Task {
                    await authViewModel.signUp()
                }
            case .none:
                break
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Password validation computed properties
    private var passwordLengthValid: Bool {
        authViewModel.password.count >= 8
    }
    
    private var passwordHasUppercase: Bool {
        authViewModel.password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    
    private var passwordHasNumber: Bool {
        authViewModel.password.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    private var passwordHasSpecialChar: Bool {
        authViewModel.password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SignupScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignupScreen(authViewModel: AuthViewModel(), isShowingSignUp: .constant(true))
    }
}