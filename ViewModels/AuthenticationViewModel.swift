//
//  AuthenticationViewModel.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

// MARK: - View Models
import AuthenticationServices

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    
    init() {
        checkAuthState()
    }
    
    private func checkAuthState() {
        if let user = Auth.auth().currentUser {
            currentUser = user
            isAuthenticated = true
            Task {
                userProfile = try? await FirebaseService.shared.fetchUserProfile(userId: user.uid)
            }
        }
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else {
            throw NSError(domain: "AuthError", code: -1)
        }
        
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nil
        )
        
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        
        await MainActor.run {
            currentUser = result.user
            isAuthenticated = true
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        userProfile = nil
        isAuthenticated = false
    }
}
