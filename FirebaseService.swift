// MARK: - Firebase Service
// FirebaseService.swift

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit
import CoreLocation

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - User Profile
    
    func createUserProfile(userId: String, displayName: String, bio: String, avatarURL: String?, completion: @escaping (Error?) -> Void) {
        let profile: [String: Any] = [
            "userId": userId,
            "displayName": displayName,
            "bio": bio,
            "avatarURL": avatarURL ?? "",
            "isVisible": true,
            "lastActive": Timestamp()
        ]
        
        db.collection("users").document(userId).setData(profile) { error in
            completion(error)
        }
    }
    
    func updateUserLocation(userId: String, location: CLLocation) {
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let geohash = LocationManager.shared.geohash(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        db.collection("users").document(userId).updateData([
            "location": geoPoint,
            "geohash": geohash,
            "lastActive": Timestamp()
        ])
    }
    
    func fetchUserProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let profile = try JSONDecoder().decode(UserProfile.self, from: jsonData)
                completion(profile)
            } catch {
                print("Error decoding profile: \(error)")
                completion(nil)
            }
        }
    }
    
    func fetchNearbyUsers(geohash: String, completion: @escaping ([UserProfile]) -> Void) {
        // Query users with similar geohash (within ~200m)
        let geohashPrefix = String(geohash.prefix(6)) // Adjust precision for ~200m radius
        
        db.collection("users")
            .whereField("geohash", isGreaterThanOrEqualTo: geohashPrefix)
            .whereField("geohash", isLessThan: geohashPrefix + "~")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let profiles = documents.compactMap { doc -> UserProfile? in
                    try? doc.data(as: UserProfile.self)
                }
                completion(profiles)
            }
    }
    
    // MARK: - Avatar Upload
    
    func uploadAvatar(userId: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let resizedImage = image.resized(to: CGSize(width: 400, height: 400)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let ref = storage.reference().child("avatars/\(userId)/profile.jpg")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error)")
                completion(nil)
                return
            }
            
            ref.downloadURL { url, error in
                completion(url?.absoluteString)
            }
        }
    }
    
    // MARK: - Connections
    
    func sendIceBreakerRequest(fromUserId: String, toUserId: String, iceBreaker: String, completion: @escaping (Error?) -> Void) {
        let connectionId = [fromUserId, toUserId].sorted().joined(separator: "_")
        
        let connection: [String: Any] = [
            "user1": fromUserId < toUserId ? fromUserId : toUserId,
            "user2": fromUserId < toUserId ? toUserId : fromUserId,
            "status": "pending",
            "initiatedBy": fromUserId,
            "iceBreaker": iceBreaker,
            "createdAt": Timestamp()
        ]
        
        db.collection("connections").document(connectionId).setData(connection) { error in
            completion(error)
        }
    }
    
    func updateConnectionStatus(connectionId: String, status: String, completion: @escaping (Error?) -> Void) {
        db.collection("connections").document(connectionId).updateData([
            "status": status
        ]) { error in
            completion(error)
        }
    }
    
    func fetchPendingConnections(userId: String, completion: @escaping ([Connection]) -> Void) {
        db.collection("connections")
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let connections = documents.compactMap { doc -> Connection? in
                    try? doc.data(as: Connection.self)
                }.filter { $0.user1 == userId || $0.user2 == userId }
                
                completion(connections)
            }
    }
    
    func fetchAcceptedConnections(userId: String, completion: @escaping ([Connection]) -> Void) {
        db.collection("connections")
            .whereField("status", isEqualTo: "accepted")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let connections = documents.compactMap { doc -> Connection? in
                    try? doc.data(as: Connection.self)
                }.filter { $0.user1 == userId || $0.user2 == userId }
                
                completion(connections)
            }
    }
    
    // MARK: - Messaging
    
    func sendMessage(connectionId: String, senderId: String, text: String, completion: @escaping (Error?) -> Void) {
        let message: [String: Any] = [
            "senderId": senderId,
            "text": text,
            "timestamp": Timestamp()
        ]
        
        db.collection("messages").document(connectionId).collection("messages").addDocument(data: message) { error in
            completion(error)
        }
    }
    
    func listenToMessages(connectionId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("messages").document(connectionId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                completion(messages)
            }
    }
}
