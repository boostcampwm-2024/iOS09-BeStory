//
//  EditUseCaseInterface.swift
//  Domain
//
//  Created by 이숲 on 12/3/24.
//

import Combine
import Core

// 테스트 용 파일입니다.
public protocol EditUseCaseInterface {
    var updatedTimeVideo: CurrentValueSubject<Video, Never> { get }
    var updatedIndexVideo: CurrentValueSubject<Video, Never> { get }

    func updateVideoTime(_ video: Video, startTime: Double, endTime: Double)
    func updateVideoIndex(_ video: Video, to index: Int)
}

public struct Video {
    let url: String
    let index: Int
    let duration: Double
    let startTime: Double
    let endTime: Double
    let frameImage: UIImageWrapper
}
