//
//  PermissionsView.swift
//  Lensly
//
//  Created by Egor Bubiryov on 11.03.2024.
//

import SwiftUI

struct PermissionsView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            
            VideoPlayerView(videoFileName: "ocean-video")
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                
                Text("Welcome to Lensly!\nExplore unique camera features, customize settings, and unleash your artistic potential!")
                    .foregroundColor(.white)
                    .font(.nunito(.extraBold, size: 25))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Spacer()
                
                accentButton(
                    title: "Access to camera",
                    isGranted: viewModel.cameraRequestIsGranted) {
                        viewModel.permissionManager.requestCameraAccess()
                    }
                
                accentButton(
                    title: "Access to library",
                    isGranted: viewModel.libraryRequestIsGranted) {
                        viewModel.permissionManager.requestLibraryAccess()
                    }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.vertical, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .background(Color.black)
    }
}

extension PermissionsView {
    func accentButton(title: String, isGranted: Bool, action: @escaping () -> Void) -> some View {
        Button {
            viewModel.permissionManager.requestCameraAccess()
        } label: {
            Text(title)
                .foregroundColor(isGranted ? .black : .white)
                .font(.nunito(.bold, size: 18))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(isGranted ? .accentYellow : .white.opacity(0.15))
                .cornerRadius(20)
        }

    }
}
#Preview {
    PermissionsView(viewModel: HomeViewModel(permissionManager: PermissionsManager()))
}
