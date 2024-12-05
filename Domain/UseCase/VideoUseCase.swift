//
//  VideoUseCase.swift
//  UseCase
//
//  Created by 디해 on 11/21/24.
//

import AVFoundation
import Combine
import Core
import Entity
import Foundation
import Interfaces

public final class VideoUseCase {
	private var cancellables: Set<AnyCancellable> = []
	private var sharedVideos: [SharedVideo] = []
    private var editingVideos = [String: Video]()
	private let sharingVideoRepository: SharingVideoRepositoryInterface
    private let editVideoRepository: EditVideoRepositoryInterface

	public let isSynchronized = PassthroughSubject<Void, Never>()
    public let startSynchronize = PassthroughSubject<Void, Never>()
    public let updatedSharedVideo = PassthroughSubject<SharedVideo, Never>()
    public let editedVideos = PassthroughSubject<[Video], Never>()
    
    public var videos: [Video] {
        editingVideos.values.sorted(by: { $0.index < $1.index })
    }
	
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
extension VideoUseCase: SharingVideoUseCaseInterface {    
    public func fetchVideos() -> [SharedVideo] {
		return sharedVideos.sorted { $0.localUrl.path < $1.localUrl.path }
	}
	
	public func shareVideo(_ url: URL, resourceName: String) {
        sharedVideos.append(
            SharedVideo(
                localUrl: url,
                name: resourceName,
                author: sharingVideoRepository.authorInformation()
            )
        )
        
		sharingVideoRepository.shareVideo(url: url, resourceName: resourceName)
	}
	
	public func synchronizeVideos() {
		sharingVideoRepository.broadcastHashes()
	}
}

// MARK: - EditVideoUseCase
extension VideoUseCase: EditVideoUseCaseInterface {
    public func fetchVideos() async -> [Video] {
        var videos = [Video]()
        let sortedVideos = sharedVideos
            .sorted { $0.localUrl.path < $1.localUrl.path }
        
        for (index, video) in sortedVideos.enumerated() {
            let duration = await duration(url: video.localUrl)
            let video = Video(
                url: video.localUrl,
                name: video.name,
                index: index,
                author: video.author,
                duration: duration
            )

            videos.append(video)
        }
        
        videos.forEach { editingVideos[$0.url.path] = $0 }
        editVideoRepository.initializedVideo(videos)
        return videos
    }
    
    public func trimmingVideo(url: URL, startTime: Double, endTime: Double) {
        guard let video = updatedVideo(url: url, startTime: startTime, endTime: endTime) else { return }
        editVideoRepository.trimmingVideo(video)
    }
    
    public func reArrangingVideo(url: URL, index: Int) {
        let videos = updatedVideos(url: url, index: index)
        editVideoRepository.reArrangingVideo(videos)
    }
}

// MARK: - Private Methods
private extension VideoUseCase {
	func bind() {
		sharingVideoRepository.updatedSharedVideo
			.sink(with: self) { owner, video in
				owner.sharedVideos.append(video)
                owner.updatedSharedVideo.send(video)
			}
			.store(in: &cancellables)
		
		sharingVideoRepository.isSynchronized
			.subscribe(isSynchronized)
			.store(in: &cancellables)
        
        sharingVideoRepository.startSynchronize
            .subscribe(startSynchronize)
            .store(in: &cancellables)
        
        editVideoRepository.editedVideos
            .sink(with: self) { owner, videos in
                owner.updateEditingVideos(videos)
                owner.editedVideos.send(videos)
            }
            .store(in: &cancellables)
	}
    
    func updateEditingVideos(_ videos: [Video]) {
        videos.forEach {
            editingVideos[$0.url.path] = $0
        }
    }
    
    func updatedVideo(url: URL, startTime: Double, endTime: Double) -> Video? {
        guard let video = editingVideos[url.path] else { return nil }
                
        let newVideo = Video(
            url: video.url,
            name: video.name,
            index: video.index,
            duration: video.duration,
            author: video.author,
            editor: video.editor,
            startTime: startTime,
            endTime: endTime
        )
        
        editingVideos[url.path] = video
        
        return newVideo
    }
    
    func updatedVideos(url: URL, index: Int) -> [Video] {
        guard let video = editingVideos[url.path] else { return [] }
        var newVideos = [Video]()
        let beforeIndex = video.index
        let adder = beforeIndex < index ? -1 : 1
        
        let lowerBound = min(beforeIndex, index)
        let upperBound = min(beforeIndex, index)
        
        let videos = editingVideos.values
            .filter { $0.index >= lowerBound && $0.index < upperBound }
            .map { updatedVideo(video: $0, index: index + adder) }

        newVideos.append(contentsOf: videos)
        newVideos.append(updatedVideo(video: video, index: index))
        newVideos.forEach { editingVideos[$0.url.path] = $0 }
        
        return newVideos
    }
    
    func updatedVideo(video: Video, index: Int) -> Video {
        return Video(
            url: video.url,
            name: video.name,
            index: video.index,
            duration: video.duration,
            author: video.author,
            editor: video.editor,
            startTime: video.startTime,
            endTime: video.endTime
        )
    }
    
    func duration(url: URL) async -> Double {
        let asset = AVAsset(url: url)
        guard let cmTimeDuration = try? await asset.load(.duration) else { return 0 }
        
        return CMTimeGetSeconds(cmTimeDuration)
    }
}
