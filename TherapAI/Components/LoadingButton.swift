import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
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
            .background(isLoading ? Color.gray : Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoadingButton(title: "Sign In", isLoading: false) {}
            LoadingButton(title: "Sign In", isLoading: true) {}
        }
        .padding()
    }
}