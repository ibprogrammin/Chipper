//
//  PendingRequestsRow.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct PendingRequestRow: View {
    let request: Connection
    @ObservedObject var viewModel: ConnectionViewModel
    @State private var isProcessing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.iceBreaker)
                .font(.body)
            
            HStack {
                Button(action: { acceptRequest() }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .disabled(isProcessing)
                
                Button(action: { declineRequest() }) {
                    Text("Decline")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .disabled(isProcessing)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func acceptRequest() {
        guard let connectionId = request.id else { return }
        isProcessing = true
        
        Task {
            do {
                try await viewModel.respondToRequest(connectionId: connectionId, accept: true)
                // Reload connections
                if let userId = Auth.auth().currentUser?.uid {
                    await viewModel.fetchConnections(userId: userId)
                }
            } catch {
                print("Error accepting request: \(error)")
            }
            isProcessing = false
        }
    }
    
    private func declineRequest() {
        guard let connectionId = request.id else { return }
        isProcessing = true
        
        Task {
            do {
                try await viewModel.respondToRequest(connectionId: connectionId, accept: false)
                // Reload connections
                if let userId = Auth.auth().currentUser?.uid {
                    await viewModel.fetchConnections(userId: userId)
                }
            } catch {
                print("Error declining request: \(error)")
            }
            isProcessing = false
        }
    }
}
