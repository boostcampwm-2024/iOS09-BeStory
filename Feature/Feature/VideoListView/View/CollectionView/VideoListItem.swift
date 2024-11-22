//
//  VideoListItem.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import Foundation

public struct VideoListItem: Hashable {
    let identifier = UUID()
    let title: String
    let authorTitle: String
    let thumbnailImage: Data
    let videoURL: URL
    let duration: String
    let date: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
