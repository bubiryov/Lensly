//
//  HomeView.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel: HomeViewModel = .init(permissionManager: PermissionsManager())
    
    var body: some View {
        ZStack {
            if viewModel.cameraRequestIsGranted, viewModel.libraryRequestIsGranted {
                CameraView()
            } else {
                permissionsScreen()
            }
        }
    }
}

#Preview {
    HomeView()
}

extension HomeView {
    func permissionsScreen() -> some View {
        VStack {
            VStack(spacing: 50) {
                Button {
                    viewModel.permissionManager.requestCameraAccess()
                } label: {
                    Text("Camera")
                        .foregroundColor(viewModel.cameraRequestIsGranted ? .green : .white)
                }
                
                Button {
                    viewModel.permissionManager.requestLibraryRequest()
                } label: {
                    Text("Library")
                        .foregroundColor(viewModel.libraryRequestIsGranted ? .green : .white)
                }

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
    }
}
