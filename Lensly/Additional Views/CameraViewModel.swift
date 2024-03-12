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
    private let focalLengthManager: FocalLengthManagerProtocol = FocalLengthManager()
    private let imageCompressor = ImageCompressor()
    private let hapticService: HapticService = .shared
    
    @Published var selectedCamera: AVCaptureDevice?
    
    @Published var rawTypes: [String : OSType] = [:]
    
    @Published var selectedFormat: PhotoFormat = .heif
    @Published var selectedFlashlightMode: FlashlightMode = .off
    @Published var selectedTimerValue: Int?
    @Published var currentTimerValue: Double?
    
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
    private var countdownTimer: AnyCancellable?

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
        handleFlashlightModeChanging()
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
    
    func startCaptureProcess() {
        hapticService.play(.light)

        guard let selectedTimerValue, selectedTimerValue > 0 else {
            capturePhoto()
            return
        }
        
        currentTimerValue = Double(selectedTimerValue)
        
        countdownTimer = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .scan(selectedTimerValue) { count, _ in
                return count >= 0 ? count - 1 : 0
            }
            .sink { [weak self] in
                self?.currentTimerValue = Double($0)
                self?.hapticService.play(.light)
                
                if $0 < 0 {
                    self?.capturePhoto()
                    self?.countdownTimer = nil
                    self?.currentTimerValue = nil
                }
            }
    }
    
    private func capturePhoto() {
        let settings = setupCaptureSettings()
        
        if selectedFlashlightMode == .torch {
            selectedFlashlightMode = .on
        }
        
        cameraService.capturePhoto(with: settings, isMirrored: selectedCamera?.position == .front)
        
    }
    
    private func setupCaptureSettings() -> AVCapturePhotoSettings {
        let settings: AVCapturePhotoSettings = {
            if selectedFormat == .raw || selectedFormat == .proRaw {
                return configurateRawFormat(rawFormat: rawTypes[selectedFormat.rawValue]!) ?? AVCapturePhotoSettings()
            } else {
                return AVCapturePhotoSettings()
            }
        }()
        
        settings.flashMode = {
            switch selectedFlashlightMode {
            case .auto: .auto
            case .off: .off
            default: .on
            }
        }()
        
        return settings
    }
    
    func handlePhotoSaving(photo: AVCapturePhoto) {
        photoLibraryService.completeAndStoreCapturedPhoto(photo: photo, format: selectedFormat) { [weak self] in
            self?.getLastPhoto()
        }
    }
        
// MARK: - Flashlight
    
    func handleFlashlightModeChanging() {
        $selectedFlashlightMode
            .sink { [weak self] in
                switch $0 {
                case .torch: self?.cameraService.toggleTorch(mode: .on)
                case .auto: self?.cameraService.toggleTorch(mode: .auto)
                default: self?.cameraService.toggleTorch(mode: .off)
                }
            }
            .store(in: &cancellables)
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
            let name = AVCapturePhotoOutput.isAppleProRAWPixelFormat($0) ? "RAW+" : "RAW"
            rawTypes[name] = $0
        }
    }
    
    private func configurateRawFormat(rawFormat: OSType) -> AVCapturePhotoSettings? {
        
        let query = AVCapturePhotoOutput.isAppleProRAWPixelFormat(rawFormat) ?
        { AVCapturePhotoOutput.isAppleProRAWPixelFormat($0) } :
        { AVCapturePhotoOutput.isBayerRAWPixelFormat($0) }
        
        guard let rawFormat =
                cameraService.output.availableRawPhotoPixelFormatTypes.first(where: query) else {
            return nil
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
