//
//  EditVideoRepositoryInterface.swift
//  Interfaces
//
//  Created by jung on 12/3/24.
//

import Combine
import Entity

public protocol EditVideoRepositoryInterface {
    var updatedVideos: PassthroughSubject<[Video], Never> { get }
    
    func trimmingVideo(_ video: Video)
    func reArrangingVideo(_ videos: [Video])
}
