// MARK: - User Detail View
// UserDetailView.swift

import SwiftUI

struct UserDetailView: View {
    let user: UserProfile
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedIceBreaker = "Hey, I'm nearby! 👋"
    @State private var showingConfirmation = false
    
    let iceBreakers = [
        "Hey, I'm nearby! 👋",
        "Want to chat?",
        "I noticed we're in the same area!",
        "Care to connect?",
        "Hi there! 😊"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Avatar
                if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.blue)
                }
                
                // Name
                Text(user.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Bio
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Ice Breaker Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose an ice breaker:")
                        .font(.headline)
                    
                    ForEach(iceBreakers, id: \.self) { iceBreaker in
                        Button {
                            selectedIceBreaker = iceBreaker
                        } label: {
                            HStack {
                                Text(iceBreaker)
                                Spacer()
                                if selectedIceBreaker == iceBreaker {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(selectedIceBreaker == iceBreaker ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                
                // Send Button
                Button {
                    sendIceBreaker()
                } label: {
                    Text("Send Ice Breaker")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Ice Breaker Sent!", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your ice breaker has been sent to \(user.displayName)")
            }
        }
    }
    
    func sendIceBreaker() {
        guard let currentUserId = authManager.currentUser?.uid else { return }
        
        FirebaseService.shared.sendIceBreakerRequest(
            fromUserId: currentUserId,
            toUserId: user.userId,
            iceBreaker: selectedIceBreaker
        ) { error in
            if error == nil {
                showingConfirmation = true
            }
        }
    }
}
