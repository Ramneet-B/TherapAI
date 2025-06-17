import SwiftUI

struct SecureTextField: View {
    let title: String
    @Binding var text: String
    @State private var isSecured = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .frame(height: 50)
            
            HStack {
                // Text Field
                Group {
                    if isSecured {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 60) // Make more room for the button
                
                Spacer()
            }
            
            // Toggle Button - positioned absolutely to prevent layout conflicts
            Button(action: {
                print("👁️ Eye button tapped - isSecured: \(isSecured)")
                
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // Toggle with animation
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSecured.toggle()
                }
                
                print("👁️ After toggle - isSecured: \(isSecured)")
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44) // Larger touch target
                    .contentShape(Rectangle()) // Ensure entire area is tappable
                    .background(Color.clear) // Invisible background for better touch
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 8)
            .allowsHitTesting(true) // Ensure button can receive touches
        }
        .allowsHitTesting(true) // Ensure container can receive touches
    }
}

struct SecureTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SecureTextField(title: "Password", text: .constant(""))
            SecureTextField(title: "Test with content", text: .constant("TestPassword123!"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}