// MARK: - App Entry Point
// NearbyConnectApp.swift

import SwiftUI
import FirebaseCore

@main
struct NearbyConnectApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
