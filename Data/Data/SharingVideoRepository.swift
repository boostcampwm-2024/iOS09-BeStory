//
//  SharingVideoRepository.swift
//  Data
//
//  Created by Yune gim on 11/18/24.
//

import Combine
import Entity
import Foundation
import Interfaces
import P2PSocket
import Core


public final class SharingVideoRepository: SharingVideoRepositoryInterface {
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: SocketProvidable

    public let updatedSharedVideo = PassthroughSubject<SharedVideo, Never>()
    public let isSynchronized = PassthroughSubject<Void, Never>()

    public init(socketProvider: SocketProvidable) {
        self.socketProvider = socketProvider
        socketProvider.resourceShared
            .compactMap { [weak self] resource in
                self?.mappingToSharedVideo(resource)
            }
            .subscribe(updatedSharedVideo)
        
        socketProvider.isSynchronized
            .subscribe(isSynchronized)
            .store(in: &cancellables)

    }
}

// MARK: - Private Methods
private extension SharingVideoRepository {
    func mappingToSharedVideo(_ resource: SharedResource) -> SharedVideo {
        return .init(localUrl: resource.localUrl, author: resource.sender)
    }
}

// MARK: - Public Methods
public extension SharingVideoRepository {
    func shareVideo(url: URL, resourceName: String) async throws {
        try await socketProvider.shareResource(url: url, resourceName: resourceName)
    }
    
    func fetchVideos() -> [SharedVideo] {
        socketProvider.sharedAllResources()
            .compactMap { [weak self] resource in
                self?.mappingToSharedVideo(resource)
            }
    }

    func synchronizeVideos() {
        let hashes = FileSystemManager.shared.collectHashes()
        socketProvider.sendHashes(hashes)
extension SharingVideoRepository {
    enum SyncMessage: Codable {
        case hash([String: String])
        case hashMatch([String: HashCondition])
        case request([String])
        case sendResponse
        case receiveResponse
        case completed
    }

}
