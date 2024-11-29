//
//  VideoUseCase.swift
//  UseCase
//
//  Created by 디해 on 11/21/24.
//

import Combine
import Entity
import Foundation
import Interfaces

public final class VideoUseCase: VideoUseCaseInterface {
    private var cancellables: Set<AnyCancellable> = []
    private var sharedVideos: [SharedVideo] = []
    private let repository: SharingVideoRepositoryInterface
    
    public let updatedVideo = PassthroughSubject<SharedVideo, Never>()
    public let isSynchronized = PassthroughSubject<Void, Never>()
    
    public init(repository: SharingVideoRepositoryInterface) {
        self.repository = repository
        bind()
    }
}

// MARK: - Public Methods
public extension VideoUseCase {
    func fetchVideos() -> [SharedVideo] {
        let sharedVideos = repository.fetchVideos()
        self.sharedVideos = sharedVideos
        return sharedVideos
    }
    
    func shareVideo(_ url: URL, resourceName: String) {
        Task {
            try? await repository.shareVideo(url: url, resourceName: resourceName)
        }
    }
    
    func synchronizeVideos() {
        repository.broadcastHashes()
    }
}

// MARK: - Private Methods
private extension VideoUseCase {
    func bind() {
        repository.updatedSharedVideo
            .subscribe(updatedVideo)
            .store(in: &cancellables)
        repository.isSynchronized
            .subscribe(isSynchronized)
            .store(in: &cancellables)
    }
}
