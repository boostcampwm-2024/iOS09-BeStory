//
//  SharingVideoRepositoryInterface.swift
//  Interfaces
//
//  Created by Yune gim on 11/18/24.
//

import Combine
import Entity
import Foundation

public protocol SharingVideoRepositoryInterface {
    var updatedSharedVideo: PassthroughSubject<SharedVideo, Never> { get }
    var isSynchronized: PassthroughSubject<Void, Never> { get }
    var startSynchronize: PassthroughSubject<Void, Never> { get }

    func shareVideo(url: URL, resourceName: String)
    func broadcastHashes()
    func authorInformation() -> String
}
