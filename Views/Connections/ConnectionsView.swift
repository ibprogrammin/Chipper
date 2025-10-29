//
//  ConnectionsView.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct ConnectionsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = ConnectionViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.pendingRequests.isEmpty {
                    Section("Pending Requests") {
                        ForEach(viewModel.pendingRequests) { request in
                            PendingRequestRow(request: request, viewModel: viewModel)
                        }
                    }
                }
                
                Section("Active Connections") {
                    if viewModel.connections.isEmpty {
                        Text("No connections yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.connections) { connection in
                            NavigationLink(destination: ChatView(connection: connection)) {
                                ConnectionRow(connection: connection)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Connections")
            .onAppear {
                loadConnections()
            }
            .refreshable {
                loadConnections()
            }
        }
    }
    
    private func loadConnections() {
        guard let userId = authViewModel.currentUser?.uid else { return }
        Task {
            await viewModel.fetchConnections(userId: userId)
        }
    }
}
