import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authViewModel = AuthViewModel()
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
            
            if isShowingSignUp {
                SignupScreen(authViewModel: authViewModel, isShowingSignUp: $isShowingSignUp)
            } else {
                LoginScreen(authViewModel: authViewModel, isShowingSignUp: $isShowingSignUp)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: authViewModel.errorMessage) { _ in
            // Clear error message after a delay
            if authViewModel.errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    authViewModel.clearError()
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}