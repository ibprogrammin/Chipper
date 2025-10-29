//
//  MapViewModel.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//


class MapViewModel: ObservableObject {
    @Published var nearbyUsers: [UserProfile] = []
    @Published var isLoading = false
    
    func fetchNearbyUsers(center: CLLocationCoordinate2D) async {
        await MainActor.run { isLoading = true }
        
        do {
            let users = try await FirebaseService.shared.fetchNearbyUsers(center: center)
            await MainActor.run {
                nearbyUsers = users
                isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Error fetching nearby users: \(error)")
        }
    }
    
    func updateLocation(userId: String, coordinate: CLLocationCoordinate2D) async {
        do {
            try await FirebaseService.shared.updateUserLocation(userId: userId, coordinate: coordinate)
        } catch {
            print("Error updating location: \(error)")
        }
    }
}
