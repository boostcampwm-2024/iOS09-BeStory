//
//  VideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/13/24.
//

import Combine
import Foundation

public protocol VideoListViewModel where Input == VideoListViewInput, Output == VideoListViewOutput {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
