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
    var location: GeoPoint?
    var geohash: String?
    var lastActive: Timestamp
    
    var coordinate: CLLocationCoordinate2D? {
        guard let location = location else { return nil }
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}
