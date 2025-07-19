import SwiftUI

struct ChatScreen: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var scrollViewID = UUID()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with rate limit status
            headerView
            
            // Messages
            messagesView
            
            // Input area
            inputView
        }
        .background(Color(.systemGray6))
        .alert("Error", isPresented: $chatViewModel.showingError) {
            Button("OK") {
                chatViewModel.showingError = false
            }
        } message: {
            Text(chatViewModel.errorMessage)
        }
        .sheet(isPresented: $chatViewModel.showingPaywall) {
            PaywallView()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TherapAI Assistant")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your AI companion for mental wellness")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button("New Conversation") {
                        chatViewModel.startNewConversation()
                    }
                    Button("Clear Messages") {
                        chatViewModel.clearConversation()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
            }
            
            // Rate limit status
            if !chatViewModel.rateLimitStatus.isEmpty {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text(chatViewModel.rateLimitStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    // AI thinking indicator
                    if chatViewModel.isLoading {
                        AIThinkingView()
                            .id("thinking")
                    }
                }
                .padding()
            }
            .onChange(of: chatViewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chatViewModel.isLoading) { isLoading in
                if isLoading {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("thinking", anchor: .bottom)
                    }
                } else {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Share your thoughts...", text: $chatViewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .lineLimit(1...4)
                    .disabled(chatViewModel.isLoading)
                
                Button(action: {
                    chatViewModel.sendMessage()
                }) {
                    Group {
                        if chatViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading
                        ? Color.gray
                        : Color.purple
                    )
                    .cornerRadius(20)
                }
                .disabled(chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(.systemGray6))
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = chatViewModel.messages.last {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        // AI Avatar
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "brain.head.profile")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            )
                        
                        Text(message.content)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    HStack {
                        Spacer(minLength: 40) // Account for avatar width
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
    }
}

struct AIThinkingView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    // AI Avatar
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                                .foregroundColor(.purple)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI is thinking...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.purple.opacity(0.6))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: animationPhase
                                    )
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
            }
            
            Spacer(minLength: 50)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            animationPhase = (animationPhase + 1) % 3
        }
    }
}

// Helper extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatScreen()
        .environmentObject(ChatViewModel())
} 