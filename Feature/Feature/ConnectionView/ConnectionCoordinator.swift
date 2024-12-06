//
//  ConnectionCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import Interfaces
import UIKit

public protocol ConnectionListener: AnyObject { }

final class ConnectionCoordinator: Coordinator, ConnectionCoordinatable {
    weak var listener: ConnectionListener?
    private let viewModel: ConnectionViewModel
    
    private let videoListContainer: VideoListContainable
    private var videoListCoordinator: Coordinatable?
    
    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        
        detachVideoList()
        viewModel.fetchBrowedUsers()
    }

    init(viewModel: ConnectionViewModel, videoListContainable: VideoListContainable) {
        self.viewModel = viewModel
        self.videoListContainer = videoListContainable
        super.init(viewController: ConnectionViewController(viewModel: viewModel))
        viewModel.coordinator = self
    }

    func attachVideoList() {
        guard videoListCoordinator == nil else { return }
        viewModel.isNotCurrentPresentedView()
        let coordinator = videoListContainer.coordinator(listener: self)
        addChild(coordinator)
        coordinator.start(navigationController)
        videoListCoordinator = coordinator
    }
    
    func detachVideoList() {
        guard let coordinator = videoListCoordinator else { return }
        
        removeChild(coordinator)
        videoListCoordinator = nil
    }
}

// MARK: -
extension ConnectionCoordinator: VideoListListener { }
