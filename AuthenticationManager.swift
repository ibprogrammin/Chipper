// MARK: - Authentication Manager
// AuthenticationManager.swift

import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var hasCompletedProfile = false
    
    private let db = Firestore.firestore()
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isAuthenticated = true
            checkProfileCompletion(userId: user.uid)
        }
    }
    
    func checkProfileCompletion(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), data["displayName"] != nil {
                self.hasCompletedProfile = true
            } else {
                self.hasCompletedProfile = false
            }
        }
    }
    
    func handleSignInWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else {
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nil
        )
        
        Auth.auth().signIn(with: firebaseCredential) { result, error in
            if let error = error {
                print("Firebase sign in error: \(error.localizedDescription)")
                return
            }
            
            if let user = result?.user {
                self.currentUser = user
                self.isAuthenticated = true
                self.checkProfileCompletion(userId: user.uid)
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
        currentUser = nil
        hasCompletedProfile = false
    }
}
