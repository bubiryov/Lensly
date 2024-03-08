//
//  PhotoLibraryService.swift
//  Lensly
//
//  Created by Egor Bubiryov on 07.03.2024.
//

import Foundation
import Photos

class PhotoLibraryService {
    
    func getLastPhoto(completion: @escaping (Data?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        if let lastAsset = fetchResult.firstObject {
            PHImageManager.default().requestImageDataAndOrientation(for: lastAsset, options: nil) { (data, _, _, _) in
                completion(data)
            }
        } else {
            completion(nil)
        }
    }
    
    func completeAndStoreCapturedPhoto(photo: AVCapturePhoto, completion: @escaping () -> Void) {
        guard let data = photo.fileDataRepresentation() else { return }
        do {
            let format = photo.isRawPhoto ? "dng" : "heif"
            let fileURL = generateTemporaryFileURL(format: format)
            try data.write(to: fileURL)
            saveToLibrary(fileURL: fileURL) {
                completion()
            }
        } catch {
            print("Error while saving photo: \(error)")
        }
    }
    
    private func saveToLibrary(fileURL: URL?, completion: @escaping () -> Void) {
        
        PHPhotoLibrary.shared().performChanges {
            
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            
            guard let fileURL else { return }
            creationRequest.addResource(with: .photo, fileURL: fileURL, options: options)
            
        } completionHandler: {success, error in
            if success {
                print("Photo saved successfully.")
                completion()
            } else if let error {
                print("Error saving photo: \(error)")
            } else {
                print("Unknown error during photo saving.")
            }
        }
    }
        
    private func generateTemporaryFileURL(format: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = ProcessInfo.processInfo.globallyUniqueString
        return tempDir.appendingPathComponent(fileName).appendingPathExtension(format)
    }

}
