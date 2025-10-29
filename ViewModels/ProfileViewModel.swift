//
//  ProfileViewModel.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

class ProfileViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var bio = ""
    @Published var selectedImage: UIImage?
    @Published var isVisible = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func saveProfile(userId: String, coordinate: CLLocationCoordinate2D) async {
        await MainActor.run { isLoading = true }
        
        do {
            var avatarURL: String?
            
            if let image = selectedImage {
                let resized = image.cropped().resized(to: CGSize(width: 400, height: 400))
                avatarURL = try await FirebaseService.shared.uploadAvatar(userId: userId, image: resized)
            }
            
            let geohash = Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude, precision: 7)
            
            let profile = UserProfile(
                userId: userId,
                displayName: displayName,
                bio: bio,
                avatarURL: avatarURL,
                isVisible: isVisible,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                geohash: geohash,
                lastActive: Date()
            )
            
            try await FirebaseService.shared.createUserProfile(profile)
            
            await MainActor.run { isLoading = false }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
