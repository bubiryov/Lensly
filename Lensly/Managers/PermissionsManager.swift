//
//  PermissionsManager.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import Foundation
import AVFoundation
import Photos

protocol PermissionsManagerProtocol: AnyObject {
    var delegate: PermissionManagerDelegate? { get set }
    func checkCameraPermissions()
    func checkLibraryPermissions()
    func requestCameraAccess()
    func requestLibraryAccess()
}

class PermissionsManager: PermissionsManagerProtocol {
    
    weak var delegate: PermissionManagerDelegate?
    
    func checkCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        handleCameraStatusChanging(status)
    }
    
    func checkLibraryPermissions() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        handleLibraryStatusChanging(status)
    }

    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] in
            if $0 { self?.delegate?.cameraAccessGranted() }
        }
    }
    
    func requestLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] in
            if $0 == .authorized {
                self?.delegate?.photoLibraryAccessGranted()
            }
        }
    }
    
    private func handleCameraStatusChanging(_ status: AVAuthorizationStatus) {
        if status == .authorized {
            delegate?.cameraAccessGranted()
        }
    }
    
    private func handleLibraryStatusChanging(_ status: PHAuthorizationStatus) {
        if status == .authorized {
            delegate?.photoLibraryAccessGranted()
        }
    }
}
