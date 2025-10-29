// MARK: - Main Tab View
// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            ConnectionsView()
                .tabItem {
                    Label("Connections", systemImage: "person.2")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
