//
//  VideoUseCaseInterface.swift
//  Interfaces
//
//  Created by 디해 on 11/21/24.
//

import Combine
import Entity
import Foundation

public protocol VideoUseCaseInterface {
    var updatedVideo: PassthroughSubject<SharedVideo, Never> { get }
    var isSynchronized: PassthroughSubject<Void, Never> { get }
    
    func fetchVideos() -> [SharedVideo]
    func shareVideo(_ url: URL, resourceName: String)
    func synchronizeVideos()
}
