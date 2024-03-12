//
//  HomeView.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel: HomeViewModel = .init(permissionManager: PermissionsManager())
    @State private var showIntro: Bool = true
    
    var body: some View {
        ZStack {
            if viewModel.cameraRequestIsGranted, viewModel.libraryRequestIsGranted {
                CameraView()
            } else {
                PermissionsView(viewModel: viewModel)
            }
            
            if showIntro {
                IntroView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showIntro = false
            }
        }
    }
}

#Preview {
    HomeView()
}
