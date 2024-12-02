//
//  MovieEditViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import AVFoundation
import Combine
import Core

public final class SharedVideoEditViewModel {
    typealias Input = SharedVideoEditViewInput
    typealias Output = SharedVideoEditViewOutput
    
    private var output = PassthroughSubject<Output, Never>()
    private var cancellables: Set<AnyCancellable> = []

    public init() {
        setupBind()
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            // 테스트 셋업으로 초기화합니다.
            case .setInitialState:
                let initialItems = [
                    VideoTimelineItem(
                        thumbnailImage: Data(),
                        duration: "0:0"
                    ),
                    VideoTimelineItem(
                        thumbnailImage: Data(),
                        duration: "10:0"
                    ),
                    VideoTimelineItem(
                        thumbnailImage: Data(),
                        duration: "20:0"
                    ),
                    VideoTimelineItem(
                        thumbnailImage: Data(),
                        duration: "30:0"
                    ),
                    VideoTimelineItem(
                        thumbnailImage: Data(),
                        duration: "40:0"
                    )
                ]
                output.send(.timeLineDidChanged(items: initialItems))
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - Private Methods
private extension SharedVideoEditViewModel {
    func setupBind() { }
	
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
