//
//  CameraView.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @StateObject var viewModel: CameraViewModel = .init()
    @State private var focusPosition: CGPoint?
    @State private var showFocusFrame: Bool = false
    @State private var selectedCameraOption: CameraOption = .exposureValue
    
    @State private var showFocusFrameTask: DispatchWorkItem?
            
    var body: some View {
        mainContent()
    }
}

#Preview {
    CameraView()
}



// MARK: - Main content

extension CameraView {
    func mainContent() -> some View {
        VStack {
            cameraViewSection()
            bottomControlSection()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.black.opacity(1))
    }
}

// MARK: - Camera section

extension CameraView {
    func cameraViewSection() -> some View {
        ZStack {
//            image()
            cameraView()
            focusFrame()
            cameraOverlayElements()
        }
        .clipped()
        .frame(height: UIScreen.main.bounds.width * 4 / 3)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.1), value: showFocusFrame)
    }
    
    func cameraView() -> some View {
        PhotoCaptureView(
            cameraService: viewModel.cameraService) {
                handlePhotoCapturing(result: $0)
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { updateFocusPoint(point: $0.location) }
            )
    }
    
    @ViewBuilder
    func focusFrame() -> some View {
        if let focusPosition, showFocusFrame {
            Image(.focus)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.accentYellow)
                .position(focusPosition)
        }
    }

    func cameraOverlayElements() -> some View {
        VStack(spacing: 0) {
            cameraLensSelectionBar()
                .padding(.bottom, 10)
            
//            cameraLenses2()
//                .padding(.bottom, 10)

            cameraOverlaySlider()
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .animation(.none, value: viewModel.selectedCamera)

    }
}

// MARK: - Camera section subcomponents

extension CameraView {
    @ViewBuilder
    func cameraLensSelectionBar() -> some View {
        let lenses = viewModel.lenses
            .filter({ $0.key.position != .front })
            .sorted(by: { $0.value < $1.value })
        
        if viewModel.selectedCamera?.position != .front {
            HStack(spacing: 10) {
                ForEach(lenses, id: \.key.uniqueID) { lens in
                    
                    let lensIsSelected = viewModel.selectedCamera == lens.key
                    
                    Button {
                        if lens.key != viewModel.selectedCamera {
                            viewModel.switchCamera(lens: lens.key)
                        }
                    } label: {
                        cameraLensButtonView(
                            lens.value.lensFormat(),
                            lensSelected: lensIsSelected)
                    }
                    .shouldBeRotatable()
                }
            }
            .padding(.horizontal, 7)
            .background(.black.opacity(0.2))
            .cornerRadius(30)
        }
    }
    
    @ViewBuilder
    func cameraOverlaySlider() -> some View {
        if UIScreen.main.nativeBounds.height <= 1920 {
            manualControlSlider()
                .tint(.accentYellow)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(.black.opacity(0.2))
        }
    }
    
    func cameraLensButtonView(_ title: String, lensSelected: Bool) -> some View {
        Text("\(title)x")
            .foregroundColor(lensSelected ? .accentYellow : .white)
            .font(.nunito(lensSelected ? .extraBold : .medium, size: 13))
            .frame(height: 30)
            .frame(maxWidth: 33)
            .contentShape(Circle())
            .background(.black.opacity(0.4))
            .clipShape(Circle())
            .padding(.vertical, 4)
            .scaleEffect(lensSelected ? 1 : 0.8)
    }
}

// MARK: - Bottom control section

extension CameraView {
    
    func bottomControlSection() -> some View {
        VStack(spacing: 0) {
            
            bottomSectionSlider()
            cameraManualControlBar()
            
            Spacer()

            bottomControlElementsRow()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func bottomSectionSlider() -> some View {
        if UIScreen.main.nativeBounds.height > 1920 {
            manualControlSlider()
                .tint(.accentYellow)
                .padding(.vertical, 10)
                .padding(.bottom, 10)
        }
    }
    
    func cameraManualControlBar() -> some View {

        let manualOptions: [(option: CameraOption, value: Any, isLocked: Bool)] = [
            (.exposureValue, viewModel.currentExposureValue, false),
            (.iso, viewModel.currentISOValue, false),
            (.shutterSpeed, viewModel.currentShutterSpeedValue, false),
            (.focus, viewModel.currentFocusValue, viewModel.selectedCamera?.position == .front),
            (.whiteBalance, viewModel.currentWhiteBalanceValue, false)
        ]
        
        return ManualControlBar(
            selectedManualOption: $selectedCameraOption,
            manualOptions: manualOptions)
    }

    func bottomControlElementsRow() -> some View {
        HStack(spacing: 30) {
            lastPhotoButton()
            backFrontSwitchButton()
            captureButton()
            restoreDefaultSettingsButton()
            universalButton(image: "settings") {
                
            }
            .frame(width: 30)
        }
        .padding(.bottom)
    }
}

// MARK: - Bottom control section subcomponents

extension CameraView {
    
    @ViewBuilder
    func lastPhotoButton() -> some View {
        
        if let lastPhoto = viewModel.lastPhoto {
            Button {
                
            } label: {
                Image(uiImage: lastPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipped()
                    .cornerRadius(5)
                    .shouldBeRotatable()
            }
        } else {
            universalButton(image: "photo") {
                switchCameraPosition()
            }
            .shouldBeRotatable()
            .frame(width: 30)
        }
    }
    
    func backFrontSwitchButton() -> some View {
        universalButton(image: "rotate") {
            switchCameraPosition()
        }
        .rotationEffect(Angle(degrees: viewModel.selectedCamera?.position == .front ? 180 : 0))
        .frame(width: 30)
    }
    
    func captureButton() -> some View {
        Button(action: {
            viewModel.capturePhoto()
        }, label: {
            Image(systemName: "circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .foregroundColor(.white)
        })
    }
    
    func restoreDefaultSettingsButton() -> some View {
        let isAutoOn: Bool = {
            return viewModel.automaticExposure && viewModel.automaticISOandShutterSpeed && viewModel.automaticFocus && viewModel.automaticWhiteBalance
        }()
        
        return universalButton(
            image: "auto",
            color: isAutoOn ? .white : .accentYellow) {
                viewModel.turnOnAutoMode()
            }
            .frame(width: 30)
    }
}

// MARK: - Other elements

extension CameraView {
    
    func manualControlSlider() -> some View {
        
        let value: Binding<Float> = {
            switch selectedCameraOption {
            case .exposureValue:
                $viewModel.currentExposureValue
            case .iso:
                $viewModel.currentISOValue
            case .shutterSpeed:
                Binding(get: {
                    Float(viewModel.currentShutterSpeedValue)
                }, set: {
                    viewModel.currentShutterSpeedValue = Int($0)
                })
            case .focus:
                $viewModel.currentFocusValue
            case .whiteBalance:
                $viewModel.currentWhiteBalanceValue
            }
        }()
        
        let range: ClosedRange<Float> = {
            switch selectedCameraOption {
            case .exposureValue:
                -8...8
            case .iso:
                viewModel.minISO...viewModel.maxISO
            case .shutterSpeed:
                Float(viewModel.maxShutterSpeed)...Float(viewModel.minShutterSpeed)
            case .focus:
                0...1
            case .whiteBalance:
                3000...8000
            }
        }()
        
        let step: Float = {
            switch selectedCameraOption {
            case .exposureValue:
                0.5
            case .iso:
                0.01
            case .shutterSpeed:
                1
            case .focus:
                0.01
            case .whiteBalance:
                1
            }
        }()
        
        let isAuto: Binding<Bool> = {
            switch selectedCameraOption {
            case .exposureValue:
                $viewModel.automaticExposure
            case .iso:
                $viewModel.automaticISOandShutterSpeed
            case .shutterSpeed:
                $viewModel.automaticISOandShutterSpeed
            case .focus:
                $viewModel.automaticFocus
            case .whiteBalance:
                $viewModel.automaticWhiteBalance
            }
        }()
        
        let unlockAction: () -> Void = {
            switch selectedCameraOption {
            case .exposureValue:
                viewModel.turnOnAutoEsposure
            case .iso:
                viewModel.turnOnAutoEsposure
            case .shutterSpeed:
                viewModel.turnOnAutoEsposure
            case .focus:
                viewModel.turnOnAutoFocus
            case .whiteBalance:
                viewModel.turnOnAutoWhiteBalance
            }
        }()
        
        return cameraValueSliderControl(
            value: value,
            in: range,
            step: step,
            isAuto: isAuto,
            unlockAction: unlockAction)
    }
    
    func cameraValueSliderControl(value: Binding<Float>, in range: ClosedRange<Float>, step: Float, isAuto: Binding<Bool>, unlockAction: @escaping () -> Void) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Slider(value: value, in: range, step: step) { _ in
                isAuto.wrappedValue = false
            }
            
            Button {
                unlockAction()
            } label: {
                Image(isAuto.wrappedValue ? .openedLock : .closedLock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .frame(width: 30)
                    .foregroundColor(isAuto.wrappedValue ? .white.opacity(0.5) : .accentYellow)
            }
            .shouldBeRotatable()
            .padding(.leading)
        }
    }
    
    func universalButton(image: String, buttonHeight: CGFloat = 23, color: Color = .white, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: buttonHeight)
                .foregroundColor(color)
        }
        .buttonStyle(.plain)
        .shouldBeRotatable()
    }
}

// MARK: - Functions

extension CameraView {
    func updateFocusPoint(point: CGPoint) {
        showFocusFrameTask?.cancel()
        focusPosition = point
        showFocusFrame = true
        viewModel.changeFocusByPoint(focusPoint: point)
        showFocusFrameTask = DispatchWorkItem {
            showFocusFrame = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: showFocusFrameTask!)
    }
    
    func handlePhotoCapturing(result: Result<AVCapturePhoto, Error>) {
        switch result {
        case .success(let photo):
            viewModel.handlePhotoSaving(photo: photo)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func switchCameraPosition() {
        let frontCamera = viewModel.lenses.first(where: { $0.key.deviceType == .builtInWideAngleCamera && $0.key.position == .front })
        let backCamera = viewModel.lenses.first(where: { $0.key.deviceType == .builtInWideAngleCamera && $0.key.position == .back })
        if let lens = viewModel.selectedCamera?.position == .back ? frontCamera : backCamera {
            withAnimation {
                viewModel.switchCamera(lens: lens.key)
            }
        }
    }
}

// MARK: Testing elements
extension View {
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

extension CameraView {
            
    func cameraLenses2() -> some View {
        
        return HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { lens in
                Button {
                    
                } label: {
                    Text("\(lens)x")
                        .foregroundColor(.accentYellow)
                        .font(.nunito(.bold, size: 13))
                        .frame(width: 30, height: 30)
                        .contentShape(Circle())
                        .background(.black.opacity(0.4))
                        .clipShape(Circle())
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 7)
        .background(.black.opacity(0.2))
        .cornerRadius(20)
    }
        
    func image() -> some View {
        Image(.picture)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.width * 4 / 3
            )
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded {
                        updateFocusPoint(point: $0.location)
                    }
            )
    }
}
