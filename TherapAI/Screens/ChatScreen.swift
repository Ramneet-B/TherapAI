import SwiftUI

struct ChatScreen: View {
    @State private var messages: [ChatMessage] = [
        .init(text: "I've been feeling really stressed lately. There's so much on my mind and I don't know where to start.", isUser: true),
        .init(text: "I'm here for you. What's been weighing on you the most?", isUser: false)
    ]
    @State private var inputText: String = ""
    
    var body: some View {
        ZStack {
            Color(.systemPurple).opacity(0.07).ignoresSafeArea()
            VStack {
                Text("Talk to Me")
                    .font(.largeTitle).bold()
                    .foregroundColor(.black)
                    .padding(.top, 24)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser { Spacer() }
                                Text(message.text)
                                    .padding()
                                    .background(message.isUser ? Color.purple.opacity(0.2) : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(18)
                                    .shadow(color: Color.purple.opacity(0.06), radius: 4, x: 0, y: 2)
                                    .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)
                                if !message.isUser { Spacer() }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal, 12)
                
                HStack {
                    TextField("Message", text: $inputText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.06), radius: 4, x: 0, y: 2)
                    
                    Button(action: {
                        // Placeholder for send action
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 8)
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen()
    }
} 