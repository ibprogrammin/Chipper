//
//  UserProfileSheet.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct UserProfileSheet: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    let user: UserProfile
    @State private var showingIceBreakers = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let urlString = user.avatarURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.gray)
                }
                
                Text(user.displayName)
                    .font(.title)
                    .bold()
                
                Text(user.bio)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: { showingIceBreakers = true }) {
                    Text("Send Ice Breaker")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingIceBreakers) {
                IceBreakerSelectionView(receiverId: user.userId)
            }
        }
    }
}
