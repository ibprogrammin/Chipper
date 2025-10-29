//
//  ProfileView.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingEditProfile = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                if let profile = authViewModel.userProfile {
                    Section {
                        HStack {
                            Spacer()
                            if let urlString = profile.avatarURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 120))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        
                LabeledContent("Name", value: profile.displayName)
                        LabeledContent("Bio", value: profile.bio)
                    }
                    
                    Section("Privacy") {
                        LabeledContent("Visible to others", value: profile.isVisible ? "Yes" : "No")
                    }
                    
                    Section {
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        showingSignOutAlert = true
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    try? authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}
