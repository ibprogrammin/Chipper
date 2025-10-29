//
//  Preview.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
