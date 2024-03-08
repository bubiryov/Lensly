//
//  CameraViewModel.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import Foundation
import Photos
import Combine
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    
    let cameraService = CameraService()
    private let photoLibraryService = PhotoLibraryService()
    private let focalLengthManager = FocalLengthManager()
    private let imageCompressor = ImageCompressor()
    
    @Published var selectedCamera: AVCaptureDevice?
    
    @Published var rawTypes: [String : OSType] = [:]
    @Published var selectedRawType: OSType?
    
    @Published var lenses: [AVCaptureDevice : Float] = [:]
    
    @Published var automaticExposure: Bool = true
    @Published var automaticISOandShutterSpeed: Bool = true
    @Published var automaticFocus: Bool = true
    @Published var automaticWhiteBalance: Bool = true
    
    @Published var currentExposureValue: Float = 0
    @Published var currentISOValue: Float = 0
    @Published var currentShutterSpeedValue: Int = 0
    @Published var currentFocusValue: Float = 0
    @Published var currentWhiteBalanceValue: Float = 0
    
    @Published var minISO: Float = 0
    @Published var maxISO: Float = 0
    
    @Published var minShutterSpeed: Int = 1000
    @Published var maxShutterSpeed: Int = 3
    
    @Published var lastPhoto: UIImage?
    
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setup()
    }
        
    private func setup() {
        subscribeToSelectedCamera()
        subscribeToOriginValues()
        subscribeToManualControlValues()
        getDeviceLenses()
        getRawFormats()
        getLastPhoto()
    }
    
    private func subscribeToOriginValues() {
        subscribeToExposure()
        subscribeToISO()
        subscribeToShutterSpeed()
        subscribeToFocus()
        subscribeToWhiteBalance()
    }
    
    private func subscribeToManualControlValues() {
        handleExposureChanging()
        handleISOandShutterSpeedChanging()
        handleFocusChanging()
        handleWhiteBalanceChanging()
    }
    
// MARK: - Selected camera settings
    
    private func subscribeToSelectedCamera() {
        cameraService.$selectedCamera
            .sink { [weak self] in
                self?.setupCamera(camera: $0)
            }
            .store(in: &cancellables)
    }
    
    private func setupCamera(camera: AVCaptureDevice?) {
        selectedCamera = camera
        minISO = camera?.activeFormat.minISO ?? 50
        maxISO = camera?.activeFormat.maxISO ?? 50
        maxShutterSpeed = camera?.activeFormat.maxExposureDuration.intShutterSpeed ?? 3
    }
    
    func switchCamera(lens: AVCaptureDevice) {
        turnOnAutoMode()
        cameraService.switchCameraLens(camera: lens)
    }
    
    func turnOnAutoMode() {
        turnOnAutoEsposure()
        turnOnAutoFocus()
        turnOnAutoWhiteBalance()
    }
    
// MARK: - Exposure
    
    private func handleExposureChanging() {
        $currentExposureValue
            .sink { [weak self] in
                self?.changeExposure(ev: $0)
            }
            .store(in: &cancellables)
    }
    
    private func changeExposure(ev: Float) {
        if !automaticExposure {
            automaticISOandShutterSpeed = true
            cameraService.changeExposureMode(camera: cameraService.selectedCamera!, mode: .continuousAutoExposure)
            cameraService.changeExposure(ev: ev)
        }
    }
    
    func turnOnAutoEsposure() {
        automaticExposure = true
        automaticISOandShutterSpeed = true
        cameraService.changeExposure(ev: 0)
        cameraService.changeExposureMode(camera: cameraService.selectedCamera!, mode: .continuousAutoExposure)
    }
    
    private func subscribeToExposure() {
        cameraService.$selectedCamera
            .compactMap { $0?.publisher(for: \.exposureTargetBias) }
            .switchToLatest()
            .sink { [weak self] in
                if let self, self.automaticExposure { currentExposureValue = $0 }
            }
            .store(in: &cancellables)
    }
    
// MARK: - ISO and shutter speed
    
    private func handleISOandShutterSpeedChanging() {
        Publishers.CombineLatest($currentISOValue, $currentShutterSpeedValue)
            .sink { [weak self] iso, shutterSpeed in
                if let self { self.changeISOandShutterSpeed(iso: iso, timescale: shutterSpeed) }
            }
            .store(in: &cancellables)
    }
    
    private func changeISOandShutterSpeed(iso: Float, timescale: Int) {
        if !automaticISOandShutterSpeed { cameraService.changeISOandShutterSpeed(iso: iso, shutterSpeed: timescale) }
    }
    
    private func subscribeToISO() {
        cameraService.$selectedCamera
            .compactMap { $0?.publisher(for: \.iso) }
            .switchToLatest()
            .sink { [weak self] in
                if let self, self.automaticISOandShutterSpeed { currentISOValue = $0 }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToShutterSpeed() {
        cameraService.$selectedCamera
            .compactMap { $0?.publisher(for: \.exposureDuration) }
            .switchToLatest()
            .sink { [weak self] in
                if let self, self.automaticISOandShutterSpeed { currentShutterSpeedValue = $0.intShutterSpeed }
            }
            .store(in: &cancellables)

    }
    
// MARK: - Focus
    
    private func handleFocusChanging() {
        $currentFocusValue
            .sink { [weak self] value in
                if let self { self.changeFocusByValue(lensPosition: value) }
            }
            .store(in: &cancellables)
    }
    
    func changeFocusByValue(lensPosition: Float) {
        if !automaticFocus { cameraService.changeFocusByValue(lensPosition) }
    }
    
    func changeFocusByPoint(focusPoint: CGPoint) {
        automaticFocus = true
        automaticExposure = true
        cameraService.changeFocusByPoint(focusPoint)
    }
    
    func turnOnAutoFocus() {
        automaticFocus = true
        if cameraService.selectedCamera?.position != .front {
            cameraService.changeFocusMode(camera: cameraService.selectedCamera!, mode: .continuousAutoFocus)
        }
    }
    
    private func subscribeToFocus() {
        cameraService.$selectedCamera
            .compactMap { $0?.publisher(for: \.lensPosition) }
            .switchToLatest()
            .sink { [weak self] in
                if let self, self.automaticFocus { currentFocusValue = $0 }
            }
            .store(in: &cancellables)
    }
    
// MARK: - White balance
    
    private func handleWhiteBalanceChanging() {
        $currentWhiteBalanceValue
            .sink { [weak self] in
                self?.changeWhiteBalanceTemperature(temperature: $0)
            }
            .store(in: &cancellables)
    }
    
    private func changeWhiteBalanceTemperature(temperature: Float) {
        if !automaticWhiteBalance { cameraService.changeWhiteBalanceTemperature(temperature: temperature)
        }
    }
    
    func turnOnAutoWhiteBalance() {
        automaticWhiteBalance = true
        cameraService.changeWhiteBalanceMode(camera: cameraService.selectedCamera!, mode: .continuousAutoWhiteBalance)
    }
    
    private func subscribeToWhiteBalance() {
        cameraService.$selectedCamera
            .compactMap { $0?.publisher(for: \.deviceWhiteBalanceGains) }
            .switchToLatest()
            .sink { [weak self] in
                if let self, let selectedCamera, self.automaticWhiteBalance {
                    self.currentWhiteBalanceValue = selectedCamera.temperatureAndTintValues(for: $0).temperature
                }
            }
            .store(in: &cancellables)
    }
    
// MARK: - Photo capturing
    
    func capturePhoto() {
        let settings: AVCapturePhotoSettings = {
            if let selectedRawType {
                return configurateRawFormat(rawFormat: selectedRawType)
            } else {
                return AVCapturePhotoSettings()
            }
        }()
        cameraService.capturePhoto(with: settings, isMirrored: selectedCamera?.position == .front)
    }
    
    func handlePhotoSaving(photo: AVCapturePhoto) {
        photoLibraryService.completeAndStoreCapturedPhoto(photo: photo) { [weak self] in
            self?.getLastPhoto()
        }
    }
    
// MARK: - Lenses
    
    private func getDeviceLenses() {
        let allLenses = cameraService.getAllCameraLenses()
        lenses = focalLengthManager.getRelativeFocalLengths(lenses: allLenses)
    }
    
// MARK: - RAW configuration
    
    private func getRawFormats() {
        let formats = cameraService.output.availableRawPhotoPixelFormatTypes
        
        formats.forEach {
            let name = AVCapturePhotoOutput.isAppleProRAWPixelFormat($0) ? "Pro RAW" : "RAW"
            rawTypes[name] = $0
        }
    }
    
    private func configurateRawFormat(rawFormat: OSType) -> AVCapturePhotoSettings {
        
        let query = AVCapturePhotoOutput.isAppleProRAWPixelFormat(rawFormat) ?
        { AVCapturePhotoOutput.isAppleProRAWPixelFormat($0) } :
        { AVCapturePhotoOutput.isBayerRAWPixelFormat($0) }
        
        guard let rawFormat =
                cameraService.output.availableRawPhotoPixelFormatTypes.first(where: query) else {
            fatalError("No RAW format found.")
        }
        return AVCapturePhotoSettings(rawPixelFormatType: rawFormat)
    }
    
// MARK: - Photo library
    
    private func getLastPhoto() {
        photoLibraryService.getLastPhoto { [weak self] in
            guard let data = $0, let uiImage = UIImage(data: data) else {
                return
            }
            self?.lastPhoto = self?.imageCompressor.compressedImage(uiImage, withQuality: 0.1)
        }
    }
}