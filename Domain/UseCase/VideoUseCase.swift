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
		return sharedVideos.sorted { $0.localUrl.path < $1.localUrl.path }
	}
	
	func shareVideo(_ url: URL, resourceName: String) {
		repository.shareVideo(url: url, resourceName: resourceName)
	}
	
	func synchronizeVideos() {
		repository.broadcastHashes()
	}
}

// MARK: - Private Methods
private extension VideoUseCase {
	func bind() {
		repository.updatedSharedVideo
			.sink(with: self) { owner, video in
				owner.sharedVideos.append(video)
				owner.updatedVideo.send(video)
			}
			.store(in: &cancellables)
		
		repository.isSynchronized
			.subscribe(isSynchronized)
			.store(in: &cancellables)
	}
}
