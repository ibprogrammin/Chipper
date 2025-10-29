//
//  ChatView.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let connection: Connection
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var otherUserProfile: UserProfile?
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == authViewModel.currentUser?.uid
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(otherUserProfile?.displayName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let connectionId = connection.id {
                viewModel.startListening(connectionId: connectionId)
            }
            loadOtherUserProfile()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty,
              let connectionId = connection.id,
              let senderId = authViewModel.currentUser?.uid else { return }
        
        messageText = ""
        
        Task {
            try? await viewModel.sendMessage(connectionId: connectionId, senderId: senderId, text: text)
        }
    }
    
    private func loadOtherUserProfile() {
        guard let currentUserId = authViewModel.currentUser?.uid else { return }
        let otherUserId = connection.user1 == currentUserId ? connection.user2 : connection.user1
        
        Task {
            otherUserProfile = try? await FirebaseService.shared.fetchUserProfile(userId: otherUserId)
        }
    }
}
