//
//  FocalLengthManager.swift
//  Lensly
//
//  Created by Egor Bubiryov on 07.03.2024.
//

import AVFoundation

class FocalLengthManager {
    func getRelativeFocalLengths(lenses: [AVCaptureDevice]) -> [AVCaptureDevice : Float] {
        
        guard let mainCameraFocalLength = getMainCameraFocalLength() else {
            return [:]
        }

        var relativeFocalLengths: [AVCaptureDevice: Float] = [:]
        
        lenses.forEach {
            let fovDegrees = $0.activeFormat.videoFieldOfView
            let fov = fovDegrees * .pi / 180
            let focalLength = Float(35.0) / (2.0 * tanf(fov / 2))
            
            let relativeFocalLength = focalLength / mainCameraFocalLength
            
            relativeFocalLengths[$0] = relativeFocalLength.rounded()
        }
        
        return relativeFocalLengths
    }
    
    private func getMainCameraFocalLength() -> Float? {
        guard let mainCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return nil
        }

        let fovDegrees = mainCamera.activeFormat.videoFieldOfView
        let fov = fovDegrees * .pi / 180
        let focalLength = 35.0 / (2.0 * tan(fov / 2))

        return focalLength.rounded()
    }
}
