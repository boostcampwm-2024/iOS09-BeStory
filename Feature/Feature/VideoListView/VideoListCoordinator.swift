//
//  VideoListCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import UIKit

public protocol VideoListListener: AnyObject { }

final class VideoListCoordinator: Coordinator, VideoListCoordinatable {
    weak var listener: VideoListListener?

    private let viewModel: MultipeerVideoListViewModel
    
    private let sharedEditVideoContainer: SharedEditVideoContainable
    private var sharedEditVideoCoordinator: Coordinatable?

    init(
        viewModel: MultipeerVideoListViewModel,
        sharedEditVideoContainer: SharedEditVideoContainable
    ) {
        self.viewModel = viewModel
        self.sharedEditVideoContainer = sharedEditVideoContainer
        let viewController = VideoListViewController(viewModel: viewModel)
        super.init(viewController: viewController)
        viewModel.coordinator = self
    }

    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func nextButtonDidTap() {
        guard sharedEditVideoCoordinator == nil else { return }
        
        let coordinator = sharedEditVideoContainer.coordinator(listener: self)
        addChild(coordinator)
        coordinator.start(navigationController)
        sharedEditVideoCoordinator = coordinator
    }
}

// MARK: - SharedVideoEditListener
extension VideoListCoordinator: SharedVideoEditListener { }
