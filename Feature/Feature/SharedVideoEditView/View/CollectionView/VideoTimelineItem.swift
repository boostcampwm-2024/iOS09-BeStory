//
//  VideoTimelineItem.swift
//  Feature
//
//  Created by 이숲 on 11/28/24.
//

import Foundation

public struct VideoTimelineItem: Hashable {
    let identifier = UUID()
    let thumbnailImage: Data
    let duration: String

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
