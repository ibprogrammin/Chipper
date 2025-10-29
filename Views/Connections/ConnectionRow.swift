//
//  ConnectionRow.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct ConnectionRow: View {
    let connection: Connection
    @State private var otherUserProfile: UserProfile?
    
    var body: some View {
        HStack {
            if let profile = otherUserProfile {
                if let urlString = profile.avatarURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text(profile.displayName)
                        .font(.headline)
                    Text("Tap to chat")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadOtherUserProfile()
        }
    }
    
    private func loadOtherUserProfile() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let otherUserId = connection.user1 == currentUserId ? connection.user2 : connection.user1
        
        Task {
            otherUserProfile = try? await FirebaseService.shared.fetchUserProfile(userId: otherUserId)
        }
    }
}
