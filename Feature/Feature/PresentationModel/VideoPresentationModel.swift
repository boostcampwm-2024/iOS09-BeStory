//
//  VideoPresentationModel.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import Core
import Foundation

struct VideoPresentationModel {
	let url: URL
	let index: Int
	let duration: Double
	let startTime: Double
	let endTime: Double
	let frameImage: UIImageWrapper
}

extension VideoPresentationModel: Equatable {
    static func == (lhs: VideoPresentationModel, rhs: VideoPresentationModel) -> Bool {
        if lhs.url == rhs.url { return true }
        return false
    }
}
