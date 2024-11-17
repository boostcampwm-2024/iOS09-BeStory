//
//  AVAsset+GenerateThumbnails.swift
//  Feature
//
//  Created by 디해 on 11/15/24.
//

import AVFoundation
import UIKit

extension AVAsset {
    func generateThumbnail() async -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else { return nil }
        let thumbnail = UIImage(cgImage: cgImage)
        return thumbnail
    }
}
