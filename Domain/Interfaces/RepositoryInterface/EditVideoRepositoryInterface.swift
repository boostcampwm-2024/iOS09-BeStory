//
//  EditVideoRepositoryInterface.swift
//  Interfaces
//
//  Created by jung on 12/3/24.
//

import Combine
import Entity

public protocol EditVideoRepositoryInterface {
    var trimmingVideo: PassthroughSubject<[Video], Never> { get }
    var reArrangingVideo: PassthroughSubject<[Video], Never> { get }
    
    func trimmingVideo(_ video: Video)
    func reArrangingVideo(_ video: Video)
}
