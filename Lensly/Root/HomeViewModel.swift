//
//  HomeViewModel.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import Foundation

protocol PermissionManagerDelegate: AnyObject {
    func cameraAccessGranted()
    func photoLibraryAccessGranted()
}

class HomeViewModel: ObservableObject, PermissionManagerDelegate {
    
    var permissionManager: PermissionsManagerProtocol
    @Published var cameraRequestIsGranted: Bool = false
    @Published var libraryRequestIsGranted: Bool = false
    
    init(permissionManager: PermissionsManagerProtocol) {
        self.permissionManager = permissionManager
        setupPermissionManager()
    }

    func cameraAccessGranted() {
        DispatchQueue.main.async { [weak self] in
            self?.cameraRequestIsGranted = true
        }
    }
    
    func photoLibraryAccessGranted() {
        DispatchQueue.main.async { [weak self] in
            self?.libraryRequestIsGranted = true
        }
    }

    private func setupPermissionManager() {
        permissionManager.delegate = self
        permissionManager.checkCameraPermissions()
        permissionManager.checkLibraryPermissions()
    }
}
