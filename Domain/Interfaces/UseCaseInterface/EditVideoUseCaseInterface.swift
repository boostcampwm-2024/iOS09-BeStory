//
//  EditVideoUseCaseInterface.swift
//  Interfaces
//
//  Created by jung on 12/3/24.
//

import Combine
import Entity
import Foundation

public protocol EditVideoUseCaseInterface {
    var editedVideos: PassthroughSubject<[Video], Never> { get }
    var videos: [Video] { get }
    
    func fetchVideos() async -> [Video]
    
    func trimmingVideo(url: URL, startTime: Double, endTime: Double)
    func reArrangingVideo(url: URL, index: Int)
}
