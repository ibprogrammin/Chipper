//
//  IceBreakerSelectionView.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct IceBreakerSelectionView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    let receiverId: String
    
    let iceBreakers = [
        "Hey, I'm nearby! 👋",
        "Want to chat?",
        "I noticed we're in the same area!",
        "Mind if I say hi? 😊",
        "Would love to connect!"
    ]
    
    var body: some View {
        NavigationView {
            List(iceBreakers, id: \.self) { iceBreaker in
                Button(action: {
                    sendIceBreaker(iceBreaker)
                }) {
                    Text(iceBreaker)
                        .padding()
                }
            }
            .navigationTitle("Choose Ice Breaker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func sendIceBreaker(_ message: String) {
        guard let senderId = authViewModel.currentUser?.uid else { return }
        
        Task {
            do {
                try await FirebaseService.shared.sendIceBreakerRequest(
                    from: senderId,
                    to: receiverId,
                    iceBreaker: message
                )
                dismiss()
            } catch {
                print("Error sending ice breaker: \(error)")
            }
        }
    }
}
