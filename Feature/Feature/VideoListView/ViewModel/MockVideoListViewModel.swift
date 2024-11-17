//
//  MockVideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/13/24.
//

import AVFoundation
import Combine

/// 비디오 리스트를 테스트하기 위한 Mock View Model
public final class MockVideoListViewModel {
    private var videoItems: [VideoListItem] = []
    
    var output = PassthroughSubject<Output, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    public init() { }
}

extension MockVideoListViewModel: VideoListViewModel {
    public func transform(
        _ input: AnyPublisher<VideoListViewInput, Never>
    ) -> AnyPublisher<VideoListViewOutput, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                guard let self else { return }
                output.send(.videoListDidChanged(videos: self.videoItems))
                
            case .appendVideo(let url):
                Task {
                    guard let self else { return }
                    let item = await self.makeVideoListItem(url: url)
                    self.videoItems.append(item)
                    self.output.send(.videoListDidChanged(videos: self.videoItems))
                }
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension MockVideoListViewModel {
    /// 비디오에 해당하는 VideoListItem을 생성합니다. 실제 데이터가 아닌 Mock 값을 넣어줍니다.
    func makeVideoListItem(url: URL) async -> VideoListItem {
        return VideoListItem(
            title: "테스트 타이틀.avi",
            authorTitle: "지혜",
            thumbnailImage: Data(),
            videoURL: url,
            duration: "2:30",
            date: "2024.07.15"
        )
    }
}
