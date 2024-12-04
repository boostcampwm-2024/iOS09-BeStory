//
//  VideoMerger.swift
//  Feature
//
//  Created by Yune gim on 12/4/24.
//

import AVFoundation
import Entity

enum VideoMerger {
    private static func addTrack(
        to composition: AVMutableComposition,
        withMediaType mediaType: AVMediaType
    ) async throws -> AVMutableCompositionTrack {
        guard let track = composition.addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
        else {
            throw NSError(domain: "CannotCreateVideoTrack", code: -2, userInfo: nil)
        }
        return track
    }

    private static func loadTrack(
        from asset: AVAsset,
        withMediaType mediaType: AVMediaType
    ) async throws -> AVAssetTrack {
        guard let track = try await asset.loadTracks(withMediaType: mediaType).first
        else {
            throw NSError(domain: "InvalidVideoTracks", code: -2, userInfo: nil)
        }
        return track
    }


private static func scaleToAspectFit(with videoSize: CGSize, to resultVideoSize: CGSize) -> CGFloat {
    let scaleX = resultVideoSize.width / videoSize.width
    let scaleY = resultVideoSize.height / videoSize.height
    let scale = min(scaleX, scaleY)
    
    return scale
}

    private static func moveToCenter(
        with videoSize: CGSize,
        to resultVideoSize: CGSize,
        scale: CGFloat
    ) -> CGPoint {
        let scaledWidth = videoSize.width * scale
        let scaledHeight = videoSize.height * scale
        let translationX = (resultVideoSize.width - scaledWidth) / 2
        let translationY = (resultVideoSize.height - scaledHeight) / 2
        
        return CGPoint(x: translationX, y: translationY)
    }
    
    private static func adoptAlphaInstruction(
        _ layerInstruction: AVMutableVideoCompositionLayerInstruction,
        currentTime: CMTime,
        duration: CMTime
    ) -> AVMutableVideoCompositionInstruction {
        layerInstruction.setOpacity(0.0, at: .zero)
        layerInstruction.setOpacity(1.0, at: currentTime)
        
        let endTime = CMTimeAdd(currentTime, duration)
        layerInstruction.setOpacity(0.0, at: endTime)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: currentTime, duration: duration)
        instruction.layerInstructions = [layerInstruction]
        
        return instruction
    }
}
