//
//  ChatViewModel.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private var listener: ListenerRegistration?
    
    func startListening(connectionId: String) {
        listener = FirebaseService.shared.listenToMessages(connectionId: connectionId) { [weak self] messages in
            DispatchQueue.main.async {
                self?.messages = messages
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    func sendMessage(connectionId: String, senderId: String, text: String) async throws {
        try await FirebaseService.shared.sendMessage(connectionId: connectionId, senderId: senderId, text: text)
    }
}
