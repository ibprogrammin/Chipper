//
//  ConnectionViewModel.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

class ConnectionViewModel: ObservableObject {
    @Published var connections: [Connection] = []
    @Published var pendingRequests: [Connection] = []
    
    func fetchConnections(userId: String) async {
        do {
            let allConnections = try await FirebaseService.shared.fetchConnections(for: userId)
            await MainActor.run {
                connections = allConnections.filter { $0.status == .accepted }
                pendingRequests = allConnections.filter { $0.status == .pending && $0.initiatedBy != userId }
            }
        } catch {
            print("Error fetching connections: \(error)")
        }
    }
    
    func sendIceBreaker(from senderId: String, to receiverId: String, message: String) async throws {
        try await FirebaseService.shared.sendIceBreakerRequest(from: senderId, to: receiverId, iceBreaker: message)
    }
    
    func respondToRequest(connectionId: String, accept: Bool) async throws {
        let status: Connection.ConnectionStatus = accept ? .accepted : .declined
        try await FirebaseService.shared.updateConnectionStatus(connectionId: connectionId, status: status)
    }
}
