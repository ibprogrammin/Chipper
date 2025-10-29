// MARK: - Profile Creation View
// ProfileCreationView.swift

import SwiftUI
import PhotosUI

struct ProfileCreationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Avatar") {
                    HStack {
                        Spacer()
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 120))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                viewModel.selectedImage = image
                            }
                        }
                    }
                }
                
                Section("Profile") {
                    TextField("Display Name", text: $viewModel.displayName)
                    TextField("Bio", text: $viewModel.bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Privacy") {
                    Toggle("Visible to nearby users", isOn: $viewModel.isVisible)
                }
                
                Section {
                    Button(action: saveProfile) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Profile")
                        }
                    }
                    .disabled(viewModel.displayName.isEmpty || viewModel.isLoading || locationManager.location == nil)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create Profile")
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }
    
    private func saveProfile() {
        guard let userId = authViewModel.currentUser?.uid,
              let location = locationManager.location else { return }
        
        Task {
            await viewModel.saveProfile(userId: userId, coordinate: location.coordinate)
            
            // Refresh user profile
            authViewModel.userProfile = try? await FirebaseService.shared.fetchUserProfile(userId: userId)
        }
    }
}
