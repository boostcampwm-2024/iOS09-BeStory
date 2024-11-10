//
//  VideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/10/24.
//

import Foundation
import Combine

public protocol VideoListViewModelInput {
    func viewDidLoad()
}

public protocol VideoListViewModelOutput {
    var videos: ReadOnlyPublisher<[VideoListPresentationModel]> { get }
}

public typealias VideoListViewModel = VideoListViewModelInput & VideoListViewModelOutput
