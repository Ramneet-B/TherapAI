import SwiftUI

struct ChatScreen: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    
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
                        ForEach(chatViewModel.messages) { message in
                            HStack {
                                if message.isFromUser { Spacer() }
                                Text(message.content)
                                    .padding()
                                    .background(message.isFromUser ? Color.purple.opacity(0.2) : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(18)
                                    .shadow(color: Color.purple.opacity(0.06), radius: 4, x: 0, y: 2)
                                    .frame(maxWidth: 260, alignment: message.isFromUser ? .trailing : .leading)
                                if !message.isFromUser { Spacer() }
                            }
                        }
                        
                        if chatViewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                Text("AI is typing...")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal, 12)
                
                HStack {
                    TextField("Message", text: $chatViewModel.inputText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.06), radius: 4, x: 0, y: 2)
                    
                    Button(action: { chatViewModel.sendMessage() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .purple)
                    }
                    .disabled(chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 8)
        }
    }
}

struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen()
            .environmentObject(ChatViewModel())
    }
} 