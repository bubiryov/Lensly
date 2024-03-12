//
//  IntroAnimation.swift
//  Lensly
//
//  Created by Egor Bubiryov on 12.03.2024.
//

import SwiftUI
import Lottie

struct IntroAnimation: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named("shutter-animation")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            animationView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            animationView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

#Preview {
    IntroAnimation()
        .frame(width: 150, height: 150)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
