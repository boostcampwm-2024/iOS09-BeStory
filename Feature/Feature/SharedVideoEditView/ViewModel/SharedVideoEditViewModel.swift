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

    private var videoPresentationModels: [VideoPresentationModel] = []
    private var tappedVideoPresentationModel: VideoPresentationModel?
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
            case .viewDidLoad:
                Task {
                    let videos = owner.usecase.fetchVideos()
                    let timelineItems = await videos.enumerated().asyncCompactMap { index, video in
                        let asset = AVAsset(url: video.url) // enumerated, index
//                        owner.usecase.trimmingVideo(
//                            url: video.url,
//                            startTime: 0,
//                            endTime: await asset.totalSeconds ?? 0
//                        )
//                        owner.usecase.reArrangingVideo(
//                            url: video.url,
//                            index: index
//                        )
                        return await owner.makeVideoTimelineItem(with: video.url, asset: asset)
                    }
                    owner.output.send(.timelineItemsDidChanged(items: timelineItems))
                }
            case .timelineCellDidTap(let url):
                let videos = owner.usecase.fetchVideos()
                guard let tappedVideo = videos.first(where: { $0.url == url }) else { return }
                print(url, tappedVideo)
                owner.setTappedVideoPresentationModel(video: tappedVideo)
            case .sliderModelLowerValueDidChanged(let value):
                owner.updateTappedVideoPresentationModel(lowerValue: value)
            case .sliderModelUpperValueDidChanged(let value):
                owner.updateTappedVideoPresentationModel(upperValue: value)
            case .sliderEditSaveButtonDidTapped:
                guard let currentTappedVideoPresentationModel = owner.tappedVideoPresentationModel else { return }
                owner.usecase.trimmingVideo(
                    url: currentTappedVideoPresentationModel.url,
                    startTime: currentTappedVideoPresentationModel.startTime,
                    endTime: currentTappedVideoPresentationModel.endTime
                )
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - Binding
private extension SharedVideoEditViewModel {
    func setupBind() {
        usecase.editedVideos
            .sink(with: self) { owner, videos in
                // Slider 길이 편집 처리
                if let currentTappedVideoPresentationModel = owner.tappedVideoPresentationModel {
                    guard let tappedVideo = videos.first(
                        where: { $0.url == currentTappedVideoPresentationModel.url }
                    ) else { return }
                    owner.setTappedVideoPresentationModel(video: tappedVideo)
                }

                // Timeline 순서 편집 처리
                Task {
                    let newTimelineItems = await videos.asyncCompactMap { video in
                        let asset = AVAsset(url: video.url)
                        return await owner.makeVideoTimelineItem(with: video.url, asset: asset)
                    }
                    owner.output.send(.timelineItemsDidChanged(items: newTimelineItems))
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private Methods for Slider
private extension SharedVideoEditViewModel {
    func setTappedVideoPresentationModel(video: Video) {
        Task {
            let asset = AVAsset(url: video.url)
            guard let frameImage = await frameImage(
                from: asset,
                frameCount: Int(video.duration) // check duration
            ) else { return }

            let model = VideoPresentationModel(
                url: video.url,
                index: video.index,
                duration: video.duration,
                startTime: video.startTime,
                endTime: video.endTime,
                frameImage: frameImage
            )

            tappedVideoPresentationModel = model
            output.send(.sliderModelDidChanged(model: model))
        }
    }

    func updateTappedVideoPresentationModel(lowerValue: Double) {
        guard let currentTappedVideoPresentationModel = tappedVideoPresentationModel else { return }
        let newModel = VideoPresentationModel(
            url: currentTappedVideoPresentationModel.url,
            index: currentTappedVideoPresentationModel.index,
            duration: currentTappedVideoPresentationModel.duration,
            startTime: lowerValue,
            endTime: currentTappedVideoPresentationModel.endTime,
            frameImage: currentTappedVideoPresentationModel.frameImage
        )

        tappedVideoPresentationModel = newModel
    }

    func updateTappedVideoPresentationModel(upperValue: Double) {
        guard let currentTappedVideoPresentationModel = tappedVideoPresentationModel else { return }
        let newModel = VideoPresentationModel(
            url: currentTappedVideoPresentationModel.url,
            index: currentTappedVideoPresentationModel.index,
            duration: currentTappedVideoPresentationModel.duration,
            startTime: currentTappedVideoPresentationModel.startTime,
            endTime: upperValue,
            frameImage: currentTappedVideoPresentationModel.frameImage
        )

        tappedVideoPresentationModel = newModel
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
