import SwiftUI

struct LoginScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue your therapy journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Login Form
                VStack(spacing: 20) {
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
                        
                        SecureTextField(title: "Enter your password", text: $authViewModel.password)
                            .focused($focusedField, equals: .password)
                            .textContentType(.password)
                    }
                    
                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign In Button
                    LoadingButton(
                        title: "Sign In",
                        isLoading: authViewModel.isLoading
                    ) {
                        Task {
                            await authViewModel.signIn()
                        }
                    }
                    .disabled(!authViewModel.isSignInFormValid)
                    .opacity(authViewModel.isSignInFormValid ? 1.0 : 0.6)
                    
                    // Demo credentials info
                    VStack(spacing: 5) {
                        Text("Demo Account")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        
                        Text("Email: demo@therapai.com")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("Password: Demo123!")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Sign Up Link
                VStack(spacing: 10) {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Create Account") {
                        isShowingSignUp = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                Task {
                    await authViewModel.signIn()
                }
            case .none:
                break
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(authViewModel: AuthViewModel(), isShowingSignUp: .constant(false))
    }
}