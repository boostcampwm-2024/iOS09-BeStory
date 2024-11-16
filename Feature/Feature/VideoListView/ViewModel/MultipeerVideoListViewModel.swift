//
//  MultipeerVideoListViewModel.swift
//  Feature
//
//  Created by 디해 on 11/13/24.
//

import Foundation
import Combine

public final class MultipeerVideoListViewModel {
    private var videos: [VideoListItem] = []
    
    var output = PassthroughSubject<Output, Never>()
    var cancellables: Set<AnyCancellable> = []
}

extension MultipeerVideoListViewModel: VideoListViewModel {
    public func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.output.send(.videoListDidChanged(videos: self?.videos ?? []))
            case .appendVideo:
                self?.appendVideoButtonTapped()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension MultipeerVideoListViewModel {
    func appendVideoButtonTapped() {
    }
}
