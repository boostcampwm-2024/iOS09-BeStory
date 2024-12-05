//
//  MainCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import Data
import P2PSocket
import UIKit
import UseCase

public final class MainCoordinator: Coordinator {
    // MARK: - Coordinatables
    private var connectionCoordinatable: ConnectionCoordinatable?
    private var videoListCoordinatable: VideoListCoordinatable?
    private var sharedVideoEditCoordinatable: SharedVideoEditCoordinatable?

    // MARK: - SocketProvider
    private let socketProvider: SocketProvidable

    // MARK: - Repositories
    private lazy var browsingUserRepository: BrowsingUserRepository = {
        return BrowsingUserRepository(socketProvider: socketProvider)
    }()
    private lazy var sharingVideoRepository: SharingVideoRepository = {
        return SharingVideoRepository(socketProvider: socketProvider)
    }()
    private lazy var editVideoRepository: EditVideoRepository = {
        return EditVideoRepository(socketProvider: socketProvider)
    }()

    // MARK: - UseCases
    private lazy var browsingUserUseCase: BrowsingUserUseCase = {
        return BrowsingUserUseCase(repository: browsingUserRepository)
    }()
    private lazy var videoUseCase: VideoUseCase = {
        return VideoUseCase(
            sharingVideoRepository: sharingVideoRepository,
            editVideoRepository: editVideoRepository
        )
    }()

    // MARK: - Initializer
    public init(socketProvider: SocketProvidable) {
        self.socketProvider = socketProvider
        super.init()
    }

    public override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)

        attachConnectionViewCoordinator()
    }
}

private extension MainCoordinator {
    func attachConnectionViewCoordinator() {
        let viewModel = ConnectionViewModel(usecase: browsingUserUseCase)
        let coordinator = ConnectionCoordinator(viewModel: viewModel)

        coordinator.listener = self
        connectionCoordinatable = coordinator
        coordinator.start(navigationController)
    }

    func attachVideoListViewCoordinator() {
        let viewModel = MultipeerVideoListViewModel(usecase: videoUseCase)
        let coordinator = VideoListCoordinator(viewModel: viewModel)
        
        coordinator.listener = self
        videoListCoordinatable = coordinator
        coordinator.start(navigationController)
    }

    func attachSharedVideoEditViewCoordinator() {
        let viewModel = SharedVideoEditViewModel(usecase: videoUseCase)
        let coordinator = SharedVideoEditCoordinator(viewModel: viewModel)

        coordinator.listener = self
        sharedVideoEditCoordinatable = coordinator
        coordinator.start(navigationController)
    }
}

extension MainCoordinator: ConnectionListener {
    func nextButtonDidTap(_ coordinator: ConnectionCoordinatable) {
        attachVideoListViewCoordinator()
    }
}

extension MainCoordinator: VideoListListener {
    func nextButtonDidTap(_ coordinator: VideoListCoordinatable) {
        attachSharedVideoEditViewCoordinator()
    }
}

extension MainCoordinator: SharedVideoEditListener {
    func nextButtonDidTap(_ coordinator: any SharedVideoEditCoordinatable) { }
}
