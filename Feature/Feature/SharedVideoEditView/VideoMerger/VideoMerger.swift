//
//  VideoMerger.swift
//  Feature
//
//  Created by Yune gim on 12/4/24.
//

import AVFoundation
import Entity

enum VideoMerger {
    private enum Constants {
        static let scaleSecond: Int32 = 600
        static let defaultFrameRate: Int32 = 30
    }

    private static func merge(
        _ videos: [Video],
        size resultSize: CGSize,
        frameRate: Int32 = Constants.defaultFrameRate
    ) async throws -> (AVMutableComposition, AVMutableVideoComposition){
        let composition = AVMutableComposition()
        var currentTime = CMTime.zero
        
        var layerInstructions: [AVMutableVideoCompositionInstruction] = []
        
        for video in videos {
            let asset = AVURLAsset(url: video.url)
            
            let assetVideoTrack = try await loadTrack(from: asset, withMediaType: .video)
            let assetAudioTrack = try await loadTrack(from: asset, withMediaType: .audio)
            
            let startTime = CMTime(seconds: video.startTime, preferredTimescale: Constants.scaleSecond)
            let duration = CMTime(seconds: video.endTime - video.startTime, preferredTimescale: Constants.scaleSecond)
            let timeRange = CMTimeRange(start: startTime, duration: duration)
            
            let videoTrack = try await addTrack(to: composition, withMediaType: .video)
            let audioTrack = try await addTrack(to: composition, withMediaType: .audio)
            
            try videoTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: currentTime)
            try audioTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: currentTime)
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            let videoSize = try await assetVideoTrack.load(.naturalSize)
            
            let scale = scaleToAspectFit(with: videoSize, to: resultSize)
            let center = moveToCenter(with: videoSize, to: resultSize, scale: scale)
            
            let transform = try await assetVideoTrack.load(.preferredTransform)
                .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
            layerInstruction.setTransform(transform, at: .zero)

            let instruction = adoptAlphaInstruction(
                layerInstruction,
                currentTime: currentTime,
                duration: duration
            )
            
            layerInstructions.append(instruction)
            currentTime = CMTimeAdd(currentTime, duration)
        }
        
        // 비디오 컴포지션 설정
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: frameRate)
        videoComposition.renderSize = resultSize
        videoComposition.instructions =  layerInstructions
        
        return (composition, videoComposition)
    }

    private static func export(
        composition: AVMutableComposition,
        videoComposition: AVMutableVideoComposition,
        outputURL: URL
    ) async throws {
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        else {
            throw NSError(domain: "CannotInitExporter", code: -2, userInfo: nil)
        }
        
        exporter.videoComposition = videoComposition

        if #available(iOS 18, *) {
            return try await exporter.export(to: outputURL, as: .mp4)
        } else {
            exporter.outputURL = outputURL
            exporter.outputFileType = .mp4
            return try await withCheckedThrowingContinuation { continuation in
                exporter.exportAsynchronously {
                    switch exporter.status {
                    case .completed:
                        continuation.resume(returning: ())
                    case .failed:
                        continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: nil))
                    case .cancelled:
                        continuation.resume(with: .failure(NSError(domain: "ExportCancelled", code: -2, userInfo: nil)))
                    default:
                        break
                    }
                }
            }
        }
    }

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
