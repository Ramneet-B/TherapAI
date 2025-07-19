import SwiftUI

// MARK: - Auth Custom TextField
struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(AuthTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .autocorrectionDisabled(keyboardType == .emailAddress)
        }
    }
}

// MARK: - Auth Custom Secure Field
struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecured = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ZStack(alignment: .trailing) {
                Group {
                    if isSecured {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(AuthTextFieldStyle())
                .autocapitalization(.none)
                .autocorrectionDisabled()
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSecured.toggle()
                    }
                }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 15)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Auth Text Field Style
struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .font(.body)
    }
}

// MARK: - Auth Custom Button
struct AuthButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? Color.purple : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper Functions
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
} 