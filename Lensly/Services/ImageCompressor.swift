//
//  ImageCompressor.swift
//  Lensly
//
//  Created by Egor Bubiryov on 07.03.2024.
//

import UIKit

class ImageCompressor {
    
    private func resizedImage(_ image: UIImage, withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: image.size.width * percentage, height: image.size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func compressedImage(_ image: UIImage, withQuality quality: Double) -> UIImage? {
        guard let imageData = image.pngData() else { return nil }
        let megaByte = 1000.0
        var resizingImage = image
        var imageSizeKB = Double(imageData.count) / megaByte

        while imageSizeKB > megaByte {
            guard let resizedImage = resizedImage(resizingImage, withPercentage: CGFloat(quality)),
                  let imageData = resizedImage.pngData() else { return nil }
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte
        }

        return resizingImage
    }
}
