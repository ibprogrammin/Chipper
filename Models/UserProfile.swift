// MARK: - Models
// UserProfile.swift

import Foundation
import CoreLocation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    var displayName: String
    var bio: String
    var avatarURL: String?
    var isVisible: Bool
    var latitude: Double
    var longitude: Double
    var geohash: String
    var lastActive: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
