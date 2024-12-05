//
//  MovieEditViewInput.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import Foundation

enum SharedVideoEditViewInput {
    case viewDidLoad
    case timelineCellDidTap(url: URL)
    case sliderModelLowerValueDidChanged(value: Double)
    case sliderModelUpperValueDidChanged(value: Double)
    case sliderEditSaveButtonDidTapped
    case nextButtonDidTap
}
