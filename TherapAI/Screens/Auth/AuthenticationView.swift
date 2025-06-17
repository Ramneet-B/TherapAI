import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingSignUp = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Group {
                if isShowingSignUp {
                    SignupScreen(authViewModel: authViewModel, isShowingSignUp: $isShowingSignUp)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .onAppear {
                            print("📱 Showing SignupScreen")
                        }
                } else {
                    LoginScreen(authViewModel: authViewModel, isShowingSignUp: $isShowingSignUp)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                        .onAppear {
                            print("📱 Showing LoginScreen")
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isShowingSignUp)
        }
        .onChange(of: authViewModel.errorMessage) {
            // Clear error message after a delay
            if authViewModel.errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    authViewModel.clearError()
                }
            }
        }
        .onChange(of: isShowingSignUp) {
            print("🔄 isShowingSignUp changed to: \(isShowingSignUp)")
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthViewModel())
    }
}