// MARK: - Sign In View
// SignInView.swift

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Chipper")
                .font(.largeTitle)
                .bold()
            
            Text("Connect with people nearby")
                .foregroundColor(.gray)
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        Task {
                            do {
                                try await authViewModel.signInWithApple(credential: credential)
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
    }
}
