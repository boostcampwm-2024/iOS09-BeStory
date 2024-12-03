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
//    private let usecase: EditUseCaseInterface

    public init() {
        self.setupBind()
    }
}

// MARK: - Transform
extension SharedVideoEditViewModel {
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink(with: self) { owner, input in
            switch input {
            // 테스트 셋업으로 초기화합니다.
            case .setInitialState:
                let videos = [
                    Video(
                        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                        duration: 5,
                        author: "test1",
                        editor: ConnectedUser(id: "a", state: .connected, name: "a"),
                        startTime: 0,
                        endTime: 5
                    ),
                    Video(
                        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
                        duration: 10,
                        author: "test2",
                        editor: ConnectedUser(id: "a", state: .connected, name: "a"),
                        startTime: 0,
                        endTime: 10
                    ),
                    Video(
                        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
                        duration: 20,
                        author: "test3",
                        editor: ConnectedUser(id: "a", state: .connected, name: "a"),
                        startTime: 0,
                        endTime: 20
                    )
                ]
                
                Task {
                    for video in videos {
                        let asset = AVAsset(url: video.url)
                        await self.appendVideoTimelineItem(with: video.url, asset: asset)
                    }
                }

//                owner.output.send(.timelineDidChanged(items: self.videoTimelineItems))
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - Binding
private extension SharedVideoEditViewModel {
    func setupBind() { }
}

// MARK: - Private Methods for Slider
private extension SharedVideoEditViewModel {
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
