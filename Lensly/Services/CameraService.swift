//
//  CameraService.swift
//  Lensly
//
//  Created by Egor Bubiryov on 24.02.2024.
//

import UIKit
import AVFoundation

class CameraService {
        
    @Published var selectedCamera: AVCaptureDevice?
    
    var captureSession: AVCaptureSession!
    
    var backWideCamera : AVCaptureDevice?
    var backUltraWideCamera: AVCaptureDevice?
    var backTelelensCamera: AVCaptureDevice?
    var frontCamera : AVCaptureDevice?
    
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
            
    init() {
        setupAndStartCaptureSession()
    }
    
// MARK: - Setup
            
    private func setupAndStartCaptureSession() {
        captureSession = AVCaptureSession()
        
        captureSession.beginConfiguration()
        
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        
        setupCameras()
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = captureSession
       
        setupOutputs()
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func setupCameras() {
        
        backWideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        backTelelensCamera = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back)
        backUltraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        if let backWideCamera { switchCameraLens(camera: backWideCamera) }
                                
    }
    
    private func setupOutputs() {
        if captureSession.canAddOutput(output) {
            output.isHighResolutionCaptureEnabled = true
            output.maxPhotoQualityPrioritization = .speed
            captureSession.addOutput(output)
        }
    }
    
// MARK: - Photo capturing
    
    func capturePhoto(with settings: AVCapturePhotoSettings, isMirrored: Bool) {
        let connection = output.connections.first
        connection?.isVideoMirrored = isMirrored
        updateOrientation(connection: connection)
        
        if let delegate { output.capturePhoto(with: settings, delegate: delegate) }
    }
    
// MARK: - Camera lenses
    
    func switchCameraLens(camera: AVCaptureDevice) {
        do {

            let currentInputs = captureSession.inputs
                .filter { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false }
            
            currentInputs
                .compactMap { $0 as? AVCaptureDeviceInput }
                .forEach { captureSession.removeInput($0) }

            let newInput = try AVCaptureDeviceInput(device: camera)

            captureSession.beginConfiguration()

            captureSession.addInput(newInput)
            
            captureSession.commitConfiguration()
            selectedCamera = camera
                                
        } catch {
            print("Error switching camera input: \(error.localizedDescription)")
        }
    }
    
    func getAllCameraLenses() -> [AVCaptureDevice] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified)
                     
        return discoverySession.devices
    }
    
// MARK: - Exposure
    
    func changeExposure(ev: Float) {
        do {
            try selectedCamera?.lockForConfiguration()
            selectedCamera?.setExposureTargetBias(ev)
            selectedCamera?.unlockForConfiguration()
        } catch {
            print("Error changing EV: \(error.localizedDescription)")
        }
    }
    
    func changeISOandShutterSpeed(iso: Float, shutterSpeed: Int) {
        do {
            try selectedCamera?.lockForConfiguration()
                        
            selectedCamera?.exposureMode = .custom
            selectedCamera?.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: Int32(shutterSpeed)), iso: iso)
                        
            selectedCamera?.unlockForConfiguration()
        } catch {
            print("Error adjusting ISO or shutter speed: \(error.localizedDescription)")
        }
    }
        
    func changeExposureMode(camera: AVCaptureDevice, mode: AVCaptureDevice.ExposureMode) {
        do {
            try camera.lockForConfiguration()
            camera.exposureMode = mode
            camera.unlockForConfiguration()
        } catch {
            print("Error changing exposure mode: \(error.localizedDescription)")
        }
    }
    
// MARK: - White balance
    
    func changeWhiteBalanceTemperature(temperature: Float) {
        do {
            try selectedCamera?.lockForConfiguration()
            
            let temperatureAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: temperature, tint: 0)
                        
            if let whiteBalanceGains = selectedCamera?.deviceWhiteBalanceGains(for: temperatureAndTintValues) {
                selectedCamera?.whiteBalanceMode = .locked
                selectedCamera?.setWhiteBalanceModeLocked(with: whiteBalanceGains)
            }
                        
            selectedCamera?.unlockForConfiguration()
        } catch {
            print("Error changing white balance temperature: \(error.localizedDescription)")
        }
    }

    func changeWhiteBalanceMode(camera: AVCaptureDevice, mode: AVCaptureDevice.WhiteBalanceMode) {
        do {
            try camera.lockForConfiguration()
            camera.whiteBalanceMode = mode
            camera.unlockForConfiguration()
        } catch {
            print("Error changing white balance mode: \(error.localizedDescription)")
        }
    }
    
// MARK: - Focus
    
    func changeFocusByValue(_ value: Float) {
        do {
            try selectedCamera?.lockForConfiguration()
            selectedCamera?.focusMode = .locked
            selectedCamera?.setFocusModeLocked(lensPosition: value)
            selectedCamera?.unlockForConfiguration()
        } catch {
            print("Error changing focus value: \(error.localizedDescription)")
        }
    }
        
    func changeFocusByPoint(_ focusPoint: CGPoint) {
        do {
            try selectedCamera?.lockForConfiguration()
            
            if selectedCamera?.isFocusPointOfInterestSupported ?? false {
                selectedCamera?.focusMode = .autoFocus
                selectedCamera?.focusPointOfInterest = focusPoint
            }
            
            if selectedCamera?.isExposurePointOfInterestSupported ?? false {
                selectedCamera?.exposurePointOfInterest = focusPoint
                selectedCamera?.exposureMode = .autoExpose
            }

            selectedCamera?.unlockForConfiguration()
        } catch {
            print("Error setting focus point of interest: \(error.localizedDescription)")
        }
    }
    
    func changeFocusMode(camera: AVCaptureDevice, mode: AVCaptureDevice.FocusMode) {
        do {
            try camera.lockForConfiguration()
            camera.focusMode = mode
            camera.unlockForConfiguration()
        } catch {
            print("Error changing focus mode: \(error.localizedDescription)")
        }
    }
    
// MARK: - Device orientation
    
    private func updateOrientation(connection: AVCaptureConnection?) {
        guard let connection else { return }
        let currentDeviceOrientation = UIDevice.current.orientation

        switch currentDeviceOrientation {
        case .portrait: connection.videoOrientation = .portrait
        case .landscapeLeft: connection.videoOrientation = .landscapeRight
        case .landscapeRight: connection.videoOrientation = .landscapeLeft
        case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
        default: connection.videoOrientation = .portrait
        }
    }
}
