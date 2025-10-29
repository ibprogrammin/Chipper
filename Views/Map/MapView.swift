// MARK: - Map View
// MapView.swift

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedUser: UserProfile?
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: viewModel.nearbyUsers) { user in
                    MapAnnotation(coordinate: user.coordinate) {
                        UserAnnotationView(user: user)
                            .onTapGesture {
                                selectedUser = user
                            }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Button(action: refreshNearbyUsers) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nearby")
            .sheet(item: $selectedUser) { user in
                UserProfileSheet(user: user)
            }
            .onAppear {
                locationManager.requestPermission()
                updateLocation()
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation {
                    region.center = location.coordinate
                    updateLocation()
                }
            }
        }
    }
    
    private func updateLocation() {
        guard let userId = authViewModel.currentUser?.uid,
              let location = locationManager.location else { return }
        
        Task {
            await viewModel.updateLocation(userId: userId, coordinate: location.coordinate)
        }
    }
    
    private func refreshNearbyUsers() {
        guard let location = locationManager.location else { return }
        
        Task {
            await viewModel.fetchNearbyUsers(center: location.coordinate)
        }
    }
}
