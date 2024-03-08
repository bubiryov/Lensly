//
//  DetectRotationModifier.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import SwiftUI

struct DetectRotationModifier: ViewModifier {
    @State private var rotationAngle: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotationAngle), anchor: .center)
            .onAppear {
                setRotationAngle()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    setRotationAngle()
                }
            }
    }
    
    private func setRotationAngle() {
        let currentOrientation = UIDevice.current.orientation
        switch currentOrientation {
        case .portraitUpsideDown:
            rotationAngle = 180
        case .landscapeLeft:
            rotationAngle = 90
        case .landscapeRight:
            rotationAngle = -90
        default:
            rotationAngle = 0
        }
    }
}
