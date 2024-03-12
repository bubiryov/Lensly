//
//  HapticService.swift
//  Lensly
//
//  Created by Egor Bubiryov on 11.03.2024.
//

import SwiftUI

class HapticService {
    static let shared = HapticService()
    
    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
