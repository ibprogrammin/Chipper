// MARK: - Content View (Main Navigation)
// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if authManager.hasCompletedProfile {
                    MainTabView()
                } else {
                    ProfileCreationView()
                }
            } else {
                SignInView()
            }
        }
    }
}
