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
    var updatedTrimmingVideos: PassthroughSubject<[Video], Never> { get }
    var updatedReArrangingVideos: PassthroughSubject<[Video], Never> { get }
    
    func fetchVideos() -> [Video]
    
    func trimmingVideo(url: URL, startTime: Double, endTime: Double)
    func reArrangingVideo(url: URL, index: Int)
}