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

protocol VideoListCoordinatable: AnyObject {
    func nextButtonDidTap()
}

public final class MultipeerVideoListViewModel {
    private var videoItems: [VideoListItem] = []
    private let usecase: SharingVideoUseCaseInterface
    
    var output = PassthroughSubject<Output, Never>()
    var cancellables: Set<AnyCancellable> = []

    weak var coordinator: VideoListCoordinatable?

    public init(usecase: SharingVideoUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }
}

private extension MultipeerVideoListViewModel {
    func setupBind() {
        usecase.updatedSharedVideo
            .sink { [weak self] updatedVideo in
                guard let self else { return }
                Task {
                    await self.appendItem(with: updatedVideo)
                }
            }
            .store(in: &cancellables)
        
        usecase.isSynchronized
            .sink { [weak self] _ in
                guard let self else { return }
                coordinator?.nextButtonDidTap()
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
            case .validateSynchronization:
                Task {
                    self.usecase.synchronizeVideos()
                }
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension MultipeerVideoListViewModel {
    func shareItem(with url: URL) async {
        Task {
            let asset = AVAsset(url: url)
            await appendItem(with: url)
            usecase.shareVideo(url, resourceName: asset.title ?? "temp.avi")
        }
    }
    
    func appendItem(with url: URL) async {
        let item = await makeVideoListItem(with: url)
        videoItems.append(item)
        output.send(.videoListDidChanged(videos: videoItems))
    }
    
    func appendItem(with sharedVideo: SharedVideo) async {
        let item = await makeVideoListItem(with: sharedVideo)
        videoItems.append(item)
        output.send(.videoListDidChanged(videos: videoItems))
    }
    
    func makeVideoListItem(with localUrl: URL) async -> VideoListItem {
        let asset = AVURLAsset(url: localUrl)
        let thumbnailImage = asset.generateThumbnail()
        let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        let durationString = convertToDurationString(with: await asset.totalSeconds)
        let formattedDate = convertToFormattedDate(with: await asset.creationDate)
        
        return VideoListItem(
            title: asset.title ?? "제목 없음",
            authorTitle: "사용자",
            thumbnailImage: thumbnailData ?? Data(),
            videoURL: localUrl,
            duration: durationString,
            date: formattedDate
        )
    }
    
    func makeVideoListItem(with sharedVideo: SharedVideo) async -> VideoListItem {
        let asset = AVURLAsset(url: sharedVideo.localUrl)
        let thumbnailImage = asset.generateThumbnail()
        let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        let durationString = convertToDurationString(with: await asset.totalSeconds)
        let formattedDate = convertToFormattedDate(with: await asset.creationDate)
        
        return VideoListItem(
            title: asset.title ?? "제목 없음",
            authorTitle: sharedVideo.author,
            thumbnailImage: thumbnailData ?? Data(),
            videoURL: sharedVideo.localUrl,
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
