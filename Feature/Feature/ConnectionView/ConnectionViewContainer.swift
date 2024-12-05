//
//  ConnectionViewContainer.swift
//  Feature
//
//  Created by jung on 12/6/24.
//

import Core
import Interfaces

public protocol ConnectionDependency {
    var videoListContaiable: VideoListContainable { get }
    var browsingUseCase: BrowsingUserUseCaseInterface { get }
}

public protocol ConnectionContainable {
    func coordinator(listener: ConnectionListener) -> Coordinatable
}

public final class ConnectionContainer:
    Container<ConnectionDependency>, ConnectionContainable {
    public func coordinator(listener: ConnectionListener) -> Coordinatable {
        let viewModel = ConnectionViewModel(usecase: dependency.browsingUseCase)
        
        let coordinator = ConnectionCoordinator(
            viewModel: viewModel,
            videoListContainable: dependency.videoListContaiable
        )
        coordinator.listener = listener
        
        return coordinator
    }
}
