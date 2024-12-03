//
//  EditVideoUseCaseInterface.swift
//  Interfaces
//
//  Created by jung on 12/3/24.
//

import Combine
import Entity

public protocol EditVideoUseCaseInterface {
    var updatedTrimmingVideo: PassthroughSubject<[Video], Never> { get }
    var updatedReArrangingVideo: PassthroughSubject<[Video], Never> { get }
    
    func fetchVideos() -> [SharedVideo]
    
    func trimmingVideo(_ video: Video)
    func reArrangingVideo(_ video: Video)
}
