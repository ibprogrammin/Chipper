// MARK: - Sign In View
// SignInView.swift

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("NearbyConnect")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Break the ice with people nearby")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        authManager.handleSignInWithApple(credential: credential)
                    }
                case .failure(let error):
                    print("Sign in error: \(error)")
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .padding()
    }
}
