//
//  VideoListCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import UIKit

protocol VideoListListener: AnyObject {
    func nextButtonDidTap(_ coordinator: VideoListCoordinatable)
}

final class VideoListCoordinator: Coordinator, VideoListCoordinatable {
    weak var listener: VideoListListener?

    private let viewController: VideoListViewController
    private let viewModel: MultipeerVideoListViewModel

    init(viewModel: MultipeerVideoListViewModel) {
        self.viewModel = viewModel
        self.viewController = VideoListViewController(viewModel: viewModel)
        super.init()
        viewModel.coordinator = self
    }

    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func nextButtonDidTap() {
        listener?.nextButtonDidTap(self)
    }
}
