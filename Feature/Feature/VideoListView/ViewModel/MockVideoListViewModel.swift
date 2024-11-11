//
//  VideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import Combine
import UIKit

final public class MockVideoListViewModel: VideoListViewModel {
    public var videos: ReadOnlyPublisher<[VideoListItem]>
    
    private func load() {
        videos.send([VideoListItem(title: "건우님이_차은우.avi",
                                                authorTitle: "from 지혜",
                                                thumbnailImage: Data.imageData() ?? Data(),
                                                duration: "2:30",
                                                date: "2024.07.15"),
                     VideoListItem(title: "지혜님이_장원영.avi",
                                                authorTitle: "from 건우",
                                                thumbnailImage: Data.imageData() ?? Data(),
                                                duration: "2:30",
                                                date: "2024.07.15")])
    }
    
    private func appendDummyVideo() {
        let dummyVideo = VideoListItem(title: "테스트_비디오.avi",
                                       authorTitle: "from 지혜",
                                       thumbnailImage: Data.imageData() ?? Data(),
                                       duration: "1:30",
                                       date: "2024.01.03")
        var currentVideos = videos.value
        currentVideos.append(dummyVideo)
        videos.send(currentVideos)
    }
    
    public init() {
        self.videos = ReadOnlyPublisher([])
    }
}

extension MockVideoListViewModel {
    public func viewDidLoad() {
        load()
    }
    
    public func appendVideo() {
        appendDummyVideo()
    }
}

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
