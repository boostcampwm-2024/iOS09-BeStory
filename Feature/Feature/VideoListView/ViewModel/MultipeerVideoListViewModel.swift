//
//  MultipeerVideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/13/24.
//

import AVFoundation
import Combine
import Core
import Entity
import Interfaces

public final class MultipeerVideoListViewModel {
    private var videoItems: [VideoListItem] = []
    private let usecase: VideoUseCaseInterface
    
    var output = PassthroughSubject<Output, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    public init(usecase: VideoUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }
}

private extension MultipeerVideoListViewModel {
    func setupBind() {
        usecase.updatedVideo
            .sink { [weak self] updatedVideo in
                guard let self else { return }
                Task {
                    let asset = AVAsset(url: updatedVideo.localUrl)
                    await self.appendItem(with: updatedVideo.localUrl, asset: asset)
                }
            }
            .store(in: &cancellables)
    }
}

extension MultipeerVideoListViewModel: VideoListViewModel {
    public func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                output.send(.videoListDidChanged(videos: self.videoItems))
            case .appendVideo(let url):
                Task {
                    await self.shareItem(with: url)
                }
                }
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension MultipeerVideoListViewModel {
    func shareItem(with url: URL) async {
        let asset = AVAsset(url: url)
        usecase.shareVideo(url, resourceName: asset.title ?? "temp.avi")
    }
    
    func appendItem(with url: URL, asset: AVAsset) async {
        let item = await makeVideoListItem(with: url, asset: asset)
        videoItems.append(item)
        output.send(.videoListDidChanged(videos: videoItems))
    }
    
    func makeVideoListItem(with url: URL, asset: AVAsset) async -> VideoListItem {
        let thumbnailImage = asset.generateThumbnail()
        let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        let durationString = convertToDurationString(with: await asset.totalSeconds)
        let formattedDate = convertToFormattedDate(with: await asset.creationDate)
        
        return VideoListItem(
            title: asset.title ?? "제목 없음",
            authorTitle: await asset.author ?? "알 수 없음",
            thumbnailImage: thumbnailData ?? Data(),
            videoURL: url,
            duration: durationString,
            date: formattedDate
        )
    }
    
    func convertToDurationString(with totalSeconds: Float64?) -> String {
        guard let totalSeconds else { return "--:--" }
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func convertToFormattedDate(with date: Date?) -> String {
        guard let date else { return "알 수 없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
