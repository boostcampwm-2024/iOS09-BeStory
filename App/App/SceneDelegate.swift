//
//  SceneDelegate.swift
//  App
//
//  Created by jung on 11/4/24.
//

import Core
import Data
import Feature
import Interfaces
import P2PSocket
import UIKit
import UseCase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
        registerDependency()

		let window = UIWindow(windowScene: windowScene)

        let groupInfoViewController = GroupInfoViewController(viewModel: DIContainer.shared.resolve(type: GroupInfoViewModel.self))
        let connectionViewController = ConnectionViewController(viewModel: DIContainer.shared.resolve(type: ConnectionViewModel.self))

        connectionViewController.onNextButton = {
            let videoListViewController = VideoListViewController(viewModel: MultipeerVideoListViewModel())
            connectionViewController.navigationController?.pushViewController(videoListViewController, animated: true)
        }

        window.rootViewController = MainViewController(
            topViewController: groupInfoViewController,
            initialViewController: connectionViewController
        )

		self.window = window
		window.makeKeyAndVisible()
	}
}

extension SceneDelegate {
    func registerDependency() {
        registerP2PSocket()
        registerRepository()
        registerUseCase()
        registerViewModel()
    }

    func registerP2PSocket() {
        DIContainer.shared.register(
            type: SocketProvidable.self,
            instance: SocketProvider()
        )
    }

    func registerRepository() {
        DIContainer.shared.register(
            type: BrowsingUserRepositoryInterface.self,
            instance: BrowsingUserRepository(
                socketProvider: DIContainer.shared.resolve(type: SocketProvidable.self)
            )
        )

        DIContainer.shared.register(
            type: ConnectedUserRepositoryInterface.self,
            instance: ConnectedUserRepository(
                socketProvider: DIContainer.shared.resolve(type: SocketProvidable.self)
            )
        )

        DIContainer.shared.register(
            type: SharingVideoRepositoryInterface.self,
            instance: SharingVideoRepository(
                socketProvider: DIContainer.shared.resolve(type: SocketProvidable.self)
            )
        )
    }

    func registerUseCase() {
        DIContainer.shared.register(
            type: BrowsingUserUseCaseInterface.self,
            instance: BrowsingUserUseCase(
                repository: DIContainer.shared.resolve(type: BrowsingUserRepositoryInterface.self)
            )
        )

        DIContainer.shared.register(
            type: ConnectedUserUseCaseInterface.self,
            instance: ConnectedUserUseCase(
                repository: DIContainer.shared.resolve(type: ConnectedUserRepositoryInterface.self)
            )
        )
    }

    func registerViewModel() {
        DIContainer.shared.register(
            type: ConnectionViewModel.self,
            instance: ConnectionViewModel(
                usecase: DIContainer.shared.resolve(type: BrowsingUserUseCaseInterface.self)
            )
        )

        DIContainer.shared.register(
            type: GroupInfoViewModel.self,
            instance: GroupInfoViewModel(
                usecase: DIContainer.shared.resolve(type: ConnectedUserUseCaseInterface.self)
            )
        )

        DIContainer.shared.register(
            type: (any VideoListViewModel).self,
            instance: MultipeerVideoListViewModel()
        )
    }
}
