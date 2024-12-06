//
//  VideoListContainer.swift
//  Feature
//
//  Created by jung on 12/6/24.
//

import Core
import Interfaces

public protocol VideoListDependency {
    var sharedEditVideoContainer: SharedEditVideoContainable { get }
    var sharingVideoUseCase: SharingVideoUseCaseInterface { get }
}

public protocol VideoListContainable {
    func coordinator(listener: VideoListListener) -> Coordinatable
}

public final class VideoListContainer:
    Container<VideoListDependency>, VideoListContainable {
    public func coordinator(listener: VideoListListener) -> Coordinatable {
        let viewModel = MultipeerVideoListViewModel(usecase: dependency.sharingVideoUseCase)
        
        let coordinator = VideoListCoordinator(
            viewModel: viewModel,
            sharedEditVideoContainer: dependency.sharedEditVideoContainer
        )
        coordinator.listener = listener
        
        return coordinator
    }
}
