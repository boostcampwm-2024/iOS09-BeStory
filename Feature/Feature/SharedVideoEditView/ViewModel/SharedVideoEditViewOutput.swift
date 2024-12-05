//
//  MovieEditViewOutput.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import Foundation

enum SharedVideoEditViewOutput {
    case timelineItemsDidChanged(items: [VideoTimelineItem])
    case sliderModelDidChanged(model: VideoPresentationModel)
}
