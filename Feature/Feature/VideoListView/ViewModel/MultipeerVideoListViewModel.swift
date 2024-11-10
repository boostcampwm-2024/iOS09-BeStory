//
//  MultipeerVideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/10/24.
//

import Foundation
import Combine

final class MultipeerVideoListViewModel: VideoListViewModel {
    var videos: ReadOnlyPublisher<[VideoListPresentationModel]>
    
    init() {
        videos = ReadOnlyPublisher([])
    }
    
    private func load() {
    }
}

extension MultipeerVideoListViewModel {
    func viewDidLoad() {
        load()
    }
}
