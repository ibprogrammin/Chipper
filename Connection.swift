// Connection.swift

import Foundation
import FirebaseFirestore

struct Connection: Identifiable, Codable {
    @DocumentID var id: String?
    let user1: String
    let user2: String
    var status: ConnectionStatus
    let initiatedBy: String
    let iceBreaker: String
    let createdAt: Timestamp
    
    enum ConnectionStatus: String, Codable {
        case pending
        case accepted
        case declined
    }
    
    func otherUserId(currentUserId: String) -> String {
        return currentUserId == user1 ? user2 : user1
    }
}
