//
//  VideoMerger.swift
//  Feature
//
//  Created by Yune gim on 12/4/24.
//

import AVFoundation
import Entity

enum VideoMerger {
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
