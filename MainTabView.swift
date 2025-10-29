// MARK: - Main Tab View
// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Nearby", systemImage: "map")
                }
            
            ConnectionsView()
                .tabItem {
                    Label("Connections", systemImage: "person.2")
                }
            
            ChatsListView()
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
