//
//  Extensions.swift
//  Lensly
//
//  Created by Egor Bubiryov on 29.02.2024.
//

import SwiftUI
import AVFoundation

extension View {
    func shouldBeRotatable() -> some View {
        modifier(DetectRotationModifier())
    }
}

extension CMTime {
    var intShutterSpeed: Int {
        return Int(self.timescale) / max(Int(value), 1)
    }
}

extension Float {
    func lensFormat() -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.1f", self)
        }
    }
    
    func formattedString() -> String {
        return String(format: "%.1f", self)
    }
}

extension Font {
    static func nunito(_ font: NunitoFont, size: CGFloat) -> Font {
        if let customFont = UIFont(name: font.rawValue, size: size) {
            return Font(customFont)
        } else {
            return Font.system(size: size)
        }
    }
}
