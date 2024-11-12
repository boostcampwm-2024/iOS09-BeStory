//
//  VideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/10/24.
//

import Combine
import Foundation

public protocol VideoListViewModelInput {
    func viewDidLoad()
    func appendVideo()
}

public protocol VideoListViewModelOutput {
    var videos: ReadOnlyPublisher<[VideoListItem]> { get }
}

public typealias VideoListViewModel = VideoListViewModelInput & VideoListViewModelOutput
