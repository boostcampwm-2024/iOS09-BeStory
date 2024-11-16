//
//  MockVideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/13/24.
//

import UIKit
import Combine

/// 비디오 리스트를 테스트하기 위한 Mock View Model
public final class MockVideoListViewModel {
    private var videos: [VideoListItem] = [
        VideoListItem(
            title: "건우님이_차은우.avi",
            authorTitle: "from 지혜",
            thumbnailImage: Data.imageData() ?? Data(),
            duration: "2:30",
            date: "2024.07.15"
        ),
        VideoListItem(
            title: "지혜님이_장원영.avi",
            authorTitle: "from 건우",
            thumbnailImage: Data.imageData() ?? Data(),
            duration: "2:30",
            date: "2024.07.15"
        )
    ]
    
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
                output.send(.videoListDidChanged(videos: self.videos))
                
            case .appendVideo:
                self?.appendDummyVideo()
                guard let self else { return }
                output.send(.videoListDidChanged(videos: self.videos))
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension MockVideoListViewModel {
    /// 테스트를 위해 Dummy Video를 추가합니다.
    func appendDummyVideo() {
        let dummyVideo = VideoListItem(
            title: "테스트_비디오.avi",
            authorTitle: "from 지혜",
            thumbnailImage: Data.imageData() ?? Data(),
            duration: "1:30",
            date: "2024.01.03"
        )
        videos.append(dummyVideo)
    }
}

// MARK: - Color Image Genenrator
private extension Data {
    static func imageData() -> Data? {
        let color = UIColor.red
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        color.setFill()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageData = image?.pngData()
        return imageData
    }
}
