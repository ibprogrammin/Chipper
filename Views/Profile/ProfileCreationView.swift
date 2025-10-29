// MARK: - Profile Creation View
// ProfileCreationView.swift

import SwiftUI
import PhotosUI

struct ProfileCreationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var displayName = ""
    @State private var bio = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var isUploading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Photo") {
                    HStack {
                        Spacer()
                        
                        if let avatarImage = avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Photo", systemImage: "photo")
                    }
                    .onChange(of: selectedPhoto) { newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                avatarImage = image
                            }
                        }
                    }
                }
                
                Section("About You") {
                    TextField("Display Name", text: $displayName)
                    
                    TextField("Bio (optional)", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: createProfile) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Complete Profile")
                        }
                    }
                    .disabled(displayName.isEmpty || isUploading)
                }
            }
            .navigationTitle("Create Profile")
        }
    }
    
    func createProfile() {
        guard let userId = authManager.currentUser?.uid else { return }
        isUploading = true
        
        if let avatarImage = avatarImage {
            FirebaseService.shared.uploadAvatar(userId: userId, image: avatarImage) { avatarURL in
                saveProfile(userId: userId, avatarURL: avatarURL)
            }
        } else {
            saveProfile(userId: userId, avatarURL: nil)
        }
    }
    
    func saveProfile(userId: String, avatarURL: String?) {
        FirebaseService.shared.createUserProfile(
            userId: userId,
            displayName: displayName,
            bio: bio,
            avatarURL: avatarURL
        ) { error in
            isUploading = false
            if error == nil {
                authManager.hasCompletedProfile = true
            }
        }
    }
}
