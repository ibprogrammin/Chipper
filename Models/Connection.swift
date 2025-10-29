// Connection.swift

import Foundation
import CoreLocation
import FirebaseFirestore

struct Connection: Identifiable, Codable {
    @DocumentID var id: String?
    let user1: String
    let user2: String
    var status: ConnectionStatus
    let initiatedBy: String
    let iceBreaker: String
    let createdAt: Date
    
    enum ConnectionStatus: String, Codable {
        case pending, accepted, declined
    }
}
