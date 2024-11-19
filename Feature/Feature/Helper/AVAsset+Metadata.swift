//
//  AVAsset+Metadata.swift
//  Feature
//
//  Created by 디해 on 11/17/24.
//

import AVFoundation

extension AVAsset {
    var metadata: [AVMetadataItem] {
        get async {
            (try? await self.load(.commonMetadata)) ?? []
        }
    }
    
    var title: String? {
        guard let urlAsset = self as? AVURLAsset else { return nil }
        let fileName = urlAsset.url.deletingPathExtension().lastPathComponent
        return fileName
    }
    
    var author: String? {
        get async {
            guard let item = await metadata.first(where: { $0.identifier == .quickTimeMetadataArtist }),
                  let stringValue = try? await item.load(.stringValue) else { return nil }
            return stringValue
        }
    }
    
    var totalSeconds: Float64? {
        get async {
            guard let duration = try? await self.load(.duration) else { return nil }
            return CMTimeGetSeconds(duration)
        }
    }
    
    var creationDate: Date? {
        get async {
            guard let item = await metadata.first(
                where: { $0.identifier == .quickTimeMetadataCreationDate }
            ) else { return nil }
            guard let dateValue = try? await item.load(.value) as? String else { return nil }
            
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: dateValue)
        }
    }
}
