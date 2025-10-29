// MARK: - Firebase Service
// FirebaseService.swift

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - User Profile
    func createUserProfile(_ profile: UserProfile) async throws {
        try db.collection("users").document(profile.userId).setData(from: profile)
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let userId = profile.id else { return }
        try db.collection("users").document(userId).setData(from: profile, merge: true)
    }
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: UserProfile.self)
    }
    
    func updateUserLocation(userId: String, coordinate: CLLocationCoordinate2D) async throws {
        let geohash = Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude, precision: 7)
        
        try await db.collection("users").document(userId).updateData([
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "geohash": geohash,
            "lastActive": FieldValue.serverTimestamp()
        ])
    }
    
    func fetchNearbyUsers(center: CLLocationCoordinate2D, radiusInMeters: Double = 200) async throws -> [UserProfile] {
        let geohash = Geohash.encode(latitude: center.latitude, longitude: center.longitude, precision: 5)
        let neighbors = Geohash.neighbors(geohash: geohash)
        
        var allUsers: [UserProfile] = []
        
        for hash in [geohash] + neighbors {
            let snapshot = try await db.collection("users")
                .whereField("geohash", isGreaterThanOrEqualTo: hash)
                .whereField("geohash", isLessThan: hash + "~")
                .whereField("isVisible", isEqualTo: true)
                .getDocuments()
            
            let users = try snapshot.documents.compactMap { try $0.data(as: UserProfile.self) }
            allUsers.append(contentsOf: users)
        }
        
        // Filter by actual distance
        return allUsers.filter { user in
            let distance = center.distance(to: user.coordinate)
            return distance <= radiusInMeters
        }
    }
    
    // MARK: - Avatar Upload
    func uploadAvatar(userId: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        let storageRef = storage.reference().child("avatars/\(userId)/profile.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    // MARK: - Connections
    func sendIceBreakerRequest(from senderId: String, to receiverId: String, iceBreaker: String) async throws {
        let connectionId = [senderId, receiverId].sorted().joined(separator: "_")
        
        let connection = Connection(
            id: connectionId,
            user1: senderId,
            user2: receiverId,
            status: .pending,
            initiatedBy: senderId,
            iceBreaker: iceBreaker,
            createdAt: Date()
        )
        
        try db.collection("connections").document(connectionId).setData(from: connection)
    }
    
    func updateConnectionStatus(connectionId: String, status: Connection.ConnectionStatus) async throws {
        try await db.collection("connections").document(connectionId).updateData([
            "status": status.rawValue
        ])
    }
    
    func fetchConnections(for userId: String) async throws -> [Connection] {
        let snapshot1 = try await db.collection("connections")
            .whereField("user1", isEqualTo: userId)
            .getDocuments()
        
        let snapshot2 = try await db.collection("connections")
            .whereField("user2", isEqualTo: userId)
            .getDocuments()
        
        let connections1 = try snapshot1.documents.compactMap { try $0.data(as: Connection.self) }
        let connections2 = try snapshot2.documents.compactMap { try $0.data(as: Connection.self) }
        
        return connections1 + connections2
    }
    
    // MARK: - Messaging
    func sendMessage(connectionId: String, senderId: String, text: String) async throws {
        let message = Message(senderId: senderId, text: text, timestamp: Date())
        try db.collection("messages").document(connectionId)
            .collection("messages").addDocument(from: message)
    }
    
    func listenToMessages(connectionId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("messages").document(connectionId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { try? $0.data(as: Message.self) }
                completion(messages)
            }
    }
}
