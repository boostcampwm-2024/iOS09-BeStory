//
//  EditVideoRepositoryInterface.swift
//  Interfaces
//
//  Created by jung on 12/3/24.
//

import Combine
import Entity

public protocol EditVideoRepositoryInterface {
    var editedVideos: PassthroughSubject<[Video], Never> { get }

    func initializedVideo(_ videos: [Video])
    func trimmingVideo(_ video: Video)
    func reArrangingVideo(_ videos: [Video])
}
