// MARK: - App Entry Point
import SwiftUI
import Firebase

@main
struct ChipperApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
