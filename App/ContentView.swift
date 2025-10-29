// MARK: - Content View (Main Navigation)
// ContentView.swift

import SwiftUI

// MARK: - Views
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.userProfile != nil {
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
