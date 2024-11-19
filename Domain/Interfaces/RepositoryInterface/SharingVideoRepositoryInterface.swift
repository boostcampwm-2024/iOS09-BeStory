//
//  SharingVideoRepositoryInterface.swift
//  Interfaces
//
//  Created by Yune gim on 11/18/24.
//

import Combine
import Entity
import Foundation
import P2PSocket

public protocol SharingVideoRepositoryInterface {
    var updatedSharedVideo: PassthroughSubject<SharedVideo, Never> { get }

    func shareVideo(url: URL, resourceName: String) async throws
    func fetchVideos() -> [SharedVideo]
}