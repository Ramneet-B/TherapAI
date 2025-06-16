import SwiftUI

struct SecureTextField: View {
    let title: String
    @Binding var text: String
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            if isSecured {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SecureTextField_Previews: PreviewProvider {
    static var previews: some View {
        SecureTextField(title: "Password", text: .constant(""))
            .padding()
    }
}