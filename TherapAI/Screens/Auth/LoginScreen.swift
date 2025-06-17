import SwiftUI

struct LoginScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 70))
                                .foregroundColor(.purple)
                            
                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Sign in to continue your therapy journey")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 60)
                        
                        // Login Form
                        VStack(spacing: 25) {
                            // Email Field
                            AuthTextField(
                                title: "Email",
                                placeholder: "Enter your email",
                                text: $authViewModel.email,
                                keyboardType: .emailAddress
                            )
                            
                            // Password Field
                            AuthSecureField(
                                title: "Password",
                                placeholder: "Enter your password",
                                text: $authViewModel.password
                            )
                            
                            // Error Message
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Sign In Button
                            AuthButton(
                                title: "Sign In",
                                isLoading: authViewModel.isLoading,
                                isEnabled: authViewModel.isSignInFormValid,
                                action: {
                                    dismissKeyboard()
                                    Task {
                                        await authViewModel.signIn()
                                    }
                                }
                            )
                            
                            // Demo credentials info
                            VStack(spacing: 8) {
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
                            .padding(16)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign Up Link
                        VStack(spacing: 15) {
                            Text("Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                print("📝 Create Account button tapped")
                                dismissKeyboard()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isShowingSignUp = true
                                }
                            }) {
                                Text("Create Account")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.bottom, 40)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarHidden(true)
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(authViewModel: AuthViewModel(), isShowingSignUp: .constant(false))
    }
}