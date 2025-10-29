// Message.swift

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let text: String
    let timestamp: Date
}
