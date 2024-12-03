//
//  MovieEditViewInput.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import Foundation

enum SharedVideoEditViewInput {
    case setInitialState
    case setCurrentVideo(url: URL)
    case lowerValueDidChanged(value: Double)
    case upperValueDidChanged(value: Double)
    case editSaveButtonDidTapped
    case editCancelButtonDidTapped
}
