//
//  MovieEditViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import AVFoundation
import Combine
import Core
import Entity
import Interfaces

public final class SharedVideoEditViewModel {
    typealias Input = SharedVideoEditViewInput
    typealias Output = SharedVideoEditViewOutput
    
    private var output = PassthroughSubject<Output, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private var videoItems: [Video] = []
    private var videoTimelineItems: [VideoTimelineItem] = []
    private var currentVideo: Video?
    private let usecase: EditVideoUseCaseInterface

    public init(usecase: EditVideoUseCaseInterface) {
        self.usecase = usecase
        self.setupBind()
    }
}

// MARK: - Transform
extension SharedVideoEditViewModel {
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink(with: self) { owner, input in
            switch input {
            case .setInitialState:
                let sharedVideos = owner.usecase.fetchVideos()

                Task {
                    for sharedVideo in sharedVideos {
                        let asset = AVAsset(url: sharedVideo.localUrl)
                        await self.appendVideoTimelineItem(with: sharedVideo.localUrl, asset: asset)
                        guard let duration = await asset.totalSeconds else { return }

                        let video = Video(
                            url: sharedVideo.localUrl,
                            name: asset.title ?? "",
                            index: owner.videoItems.count,
                            author: sharedVideo.author,
                            duration: Double(duration)
                        )
                        owner.videoItems.append(video)
                    }
                }
            case .setCurrentVideo(let url):
                owner.setCurrentVideo(url: url)
            case .lowerValueDidChanged(let value):
                owner.currentVideo?.startTime = value
                owner.setCurrentVideo()
            case .upperValueDidChanged(let value):
                owner.currentVideo?.endTime = value
                owner.setCurrentVideo()
            case .editSaveButtonDidTapped:
                guard let currentVideo = owner.currentVideo else { return }
                guard let index = owner.videoItems.firstIndex(where: { $0.url == currentVideo.url }) else { return }
                owner.videoItems[index] = currentVideo
                owner.usecase.trimmingVideo(currentVideo)
            case .editCancelButtonDidTapped:
                guard let currentVideo = owner.currentVideo else { return }
                owner.currentVideo = owner.videoItems.first(where: { $0.url == currentVideo.url })
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - Binding
private extension SharedVideoEditViewModel {
    func setupBind() {
        usecase.updatedReArrangingVideo
            .sink(with: self) { owner, video in
            }
            .store(in: &cancellables)

        usecase.updatedTrimmingVideo
            .sink(with: self) { owner, videos in
                owner.videoItems = videos
                if videos.contains(where: { $0.url == owner.currentVideo?.url }) {
                    guard let url = owner.currentVideo?.url else { return }
                    owner.setCurrentVideo(url: url)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private Methods for Slider
private extension SharedVideoEditViewModel {
    func setCurrentVideo(url: URL) {
        guard let currentVideo = videoItems.first(where: { $0.url == url }) else { return }
        self.currentVideo = currentVideo
        guard let index = videoItems.firstIndex(where: { $0.url == url }) else { return }

        Task {
            let asset = AVAsset(url: currentVideo.url)
            guard let frameImage = await frameImage(
                from: asset,
                frameCount: Int(currentVideo.duration)
            ) else { return }

            let item = VideoPresentationModel(
                url: currentVideo.url,
                index: index,
                duration: currentVideo.duration,
                startTime: currentVideo.startTime,
                endTime: currentVideo.endTime,
                frameImage: frameImage
            )

            output.send(.sliderDidChanged(item: item))
        }
    }

    func setCurrentVideo() {
        guard let currentVideo = currentVideo else { return }

        Task {
            let asset = AVAsset(url: currentVideo.url)
            guard let frameImage = await frameImage(
                from: asset,
                frameCount: Int(currentVideo.duration)
            ) else { return }

            let item = VideoPresentationModel(
                url: currentVideo.url,
                index: currentVideo.index,
                duration: currentVideo.duration,
                startTime: currentVideo.startTime,
                endTime: currentVideo.endTime,
                frameImage: frameImage
            )

            output.send(.sliderDidChanged(item: item))
        }
    }

	/// `frameCount` 만큼의  frame Image들을 단일 frameImage로 리턴해줍니다.
	func frameImage(from video: AVAsset, frameCount: Int) async -> UIImageWrapper? {
		guard let cmTimeDuration = try? await video.load(.duration) else { return nil }
		let secondsDuration = Int(CMTimeGetSeconds(cmTimeDuration))
		let singleFrameDuration = Double(secondsDuration) / Double(frameCount)
		
		let frameCMTimes = (0..<frameCount).map { index -> CMTime in
			let startTime = singleFrameDuration * Double(index)
			
			return CMTimeMakeWithSeconds(startTime, preferredTimescale: Int32(secondsDuration))
		}
		
		let generator = avAssetImageGenerator(from: video)
		
		return await frameImage(from: generator, times: frameCMTimes)
	}
	
	func avAssetImageGenerator(from video: AVAsset) -> AVAssetImageGenerator {
		let generator = AVAssetImageGenerator(asset: video)
		generator.appliesPreferredTrackTransform = true
		generator.requestedTimeToleranceAfter = CMTime.zero
		generator.requestedTimeToleranceBefore = CMTime.zero
		
		return generator
	}
	
	func frameImage(from generator: AVAssetImageGenerator, times: [CMTime]) async -> UIImageWrapper? {
		var resultImages = Array(repeating: UIImageWrapper(), count: times.count)
		
		await withTaskGroup(of: Void.self) { group in
			for (index, time) in times.enumerated() {
				group.addTask {
					guard let image = try? await generator.generateUIImage(at: time) else { return }
					resultImages[index] = .init(image: image)
				}
			}
		}
		
		let concatImage = resultImages.map { $0.image }.concatImagesHorizontaly()
		
		return .init(image: concatImage)
	}
}

// MARK: - Private Methods for Timeline
private extension SharedVideoEditViewModel {
    func appendVideoTimelineItem(with url: URL, asset: AVAsset) async {
        let item = await makeVideoTimelineItem(with: url, asset: asset)
        videoTimelineItems.append(item)
        output.send(.timelineDidChanged(items: videoTimelineItems))
    }

    func makeVideoTimelineItem(with url: URL, asset: AVAsset) async -> VideoTimelineItem {
        let thumbnailImage = asset.generateThumbnail()
        let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        let durationString = convertToDurationString(with: await asset.totalSeconds)

        return VideoTimelineItem(
            url: url,
            thumbnailImage: thumbnailData ?? Data(),
            duration: durationString
        )
    }

    func convertToDurationString(with totalSeconds: Float64?) -> String {
        guard let totalSeconds else { return "--:--" }
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
