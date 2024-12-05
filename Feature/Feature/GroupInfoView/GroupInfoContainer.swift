//
//  GroupInfoContainer.swift
//  Feature
//
//  Created by jung on 12/6/24.
//

import Core
import Interfaces

public protocol GroupInfoDependency {
    var videoListContaiable: VideoListContainable { get }
    var connectedUserUseCase: ConnectedUserUseCaseInterface { get }
}

public protocol GroupInfoContainable {
    func coordinator(listener: GroupInfoListener) -> Coordinatable
}

public final class GroupInfoContainer:
    Container<GroupInfoDependency>, GroupInfoContainable {
    public func coordinator(listener: GroupInfoListener) -> Coordinatable {
        let viewModel = GroupInfoViewModel(usecase: dependency.connectedUserUseCase)
        
        let coordinator = GroupInfoCoordinator(viewModel: viewModel)
        coordinator.listener = listener
        
        return coordinator
    }
}
