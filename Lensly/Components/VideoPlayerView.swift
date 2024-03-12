//
//  VideoPlayerView.swift
//  Lensly
//
//  Created by Egor Bubiryov on 11.03.2024.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    var videoFileName: String

    func makeUIViewController(context: Context) -> UIViewController {
        let player = AVPlayer(url: Bundle.main.url(forResource: videoFileName, withExtension: "mp4")!)
        let playerViewController = UIViewController()

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerViewController.view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerViewController.view.layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        player.play()

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
