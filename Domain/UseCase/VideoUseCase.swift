//
//  VideoUseCase.swift
//  UseCase
//
//  Created by 디해 on 11/21/24.
//

import Combine
import Core
import Entity
import Foundation
import Interfaces

public final class VideoUseCase {
	private var cancellables: Set<AnyCancellable> = []
	private var sharedVideos: [SharedVideo] = []
	private let sharingVideoRepository: SharingVideoRepositoryInterface
    private let editVideoRepository: EditVideoRepositoryInterface

	public let updatedVideo = PassthroughSubject<SharedVideo, Never>()
	public let isSynchronized = PassthroughSubject<Void, Never>()
    
    public let updatedTrimmingVideo = PassthroughSubject<[Video], Never>()
    public let updatedReArrangingVideo = PassthroughSubject<[Video], Never>()
	
    public init(
        sharingVideoRepository: SharingVideoRepositoryInterface,
        editVideoRepository: EditVideoRepositoryInterface
    ) {
		self.sharingVideoRepository = sharingVideoRepository
        self.editVideoRepository = editVideoRepository
		bind()
	}
}

// MARK: - VideoUseCaseInterface
extension VideoUseCase: VideoUseCaseInterface {    
    public func fetchVideos() -> [SharedVideo] {
		return sharedVideos.sorted { $0.localUrl.path < $1.localUrl.path }
	}
	
	public func shareVideo(_ url: URL, resourceName: String) {
		sharingVideoRepository.shareVideo(url: url, resourceName: resourceName)
	}
	
	public func synchronizeVideos() {
		sharingVideoRepository.broadcastHashes()
	}
}

// MARK: - EditVideoUseCase
extension VideoUseCase: EditVideoUseCaseInterface {
    public func trimmingVideo(_ video: Video) {
        editVideoRepository.trimmingVideo(video)
    }
    
    public func reArrangingVideo(_ video: Video) {
        editVideoRepository.reArrangingVideo(video)
    }
}

// MARK: - Private Methods
private extension VideoUseCase {
	func bind() {
		sharingVideoRepository.updatedSharedVideo
			.sink(with: self) { owner, video in
				owner.sharedVideos.append(video)
				owner.updatedVideo.send(video)
			}
			.store(in: &cancellables)
		
		sharingVideoRepository.isSynchronized
			.subscribe(isSynchronized)
			.store(in: &cancellables)
        
        editVideoRepository.trimmingVideo
            .subscribe(updatedTrimmingVideo)
            .store(in: &cancellables)
        
        editVideoRepository.reArrangingVideo
            .subscribe(updatedReArrangingVideo)
            .store(in: &cancellables)
	}
}
