// MARK: - Map View
// MapView.swift

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var nearbyUsers: [UserProfile] = []
    @State private var selectedUser: UserProfile?
    @State private var showingUserDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: nearbyUsers) { user in
                    MapAnnotation(coordinate: user.coordinate ?? CLLocationCoordinate2D()) {
                        Button {
                            selectedUser = user
                            showingUserDetail = true
                        } label: {
                            UserMapMarker(user: user)
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Button {
                        refreshNearbyUsers()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nearby")
            .sheet(isPresented: $showingUserDetail) {
                if let user = selectedUser {
                    UserDetailView(user: user)
                }
            }
            .onAppear {
                setupLocation()
            }
        }
    }
    
    func setupLocation() {
        locationManager.requestPermission()
        locationManager.startUpdating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let location = locationManager.location {
                region.center = location.coordinate
                updateUserLocation(location: location)
                refreshNearbyUsers()
            }
        }
    }
    
    func updateUserLocation(location: CLLocation) {
        guard let userId = authManager.currentUser?.uid else { return }
        FirebaseService.shared.updateUserLocation(userId: userId, location: location)
    }
    
    func refreshNearbyUsers() {
        guard let location = locationManager.location else { return }
        let geohash = locationManager.geohash(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        FirebaseService.shared.fetchNearbyUsers(geohash: geohash) { users in
            // Filter out current user
            self.nearbyUsers = users.filter { $0.userId != authManager.currentUser?.uid }
        }
    }
}

struct UserMapMarker: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 4) {
            if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            Text(user.displayName)
                .font(.caption2)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
        }
    }
}
