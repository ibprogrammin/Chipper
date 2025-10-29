//
//  UserAnnotationView.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct UserAnnotationView: View {
    let user: UserProfile
    
    var body: some View {
        VStack {
            if let urlString = user.avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            Text(user.displayName)
                .font(.caption)
                .padding(4)
                .background(Color.white.opacity(0.8))
                .cornerRadius(4)
        }
    }
}
