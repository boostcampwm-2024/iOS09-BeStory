//
//  SceneDelegate.swift
//  App
//
//  Created by jung on 11/4/24.
//

import Data
import DataInterface
import Feature
import Interfaces
import UIKit
import UseCase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

        registerDependencies()

		let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ConnectionViewController(
            viewModel: DIContainer.shared.resolve(type: ConnectionViewModel.self)
        )
		self.window = window
		window.makeKeyAndVisible()
	}
}

private extension SceneDelegate {
    func registerDependencies() {
        // MARK: - Socket Provider

        DIContainer.shared.register(
            type: SocketProvider.self,
            instance: SocketProvider()
        )

        // MARK: - Repository

        DIContainer.shared.register(
            type: BrowsingUserRepository.self,
            instance: BrowsingUserRepository(
                socketProvider: DIContainer.shared.resolve(type: SocketProvider.self)
            )
        )

        DIContainer.shared.register(
            type: ConnectedUserRepository.self,
            instance: ConnectedUserRepository(
                socketProvider: DIContainer.shared.resolve(type: SocketProvider.self)
            )
        )

        // MARK: - UseCase

        DIContainer.shared.register(
            type: BrowsingUserUseCase.self,
            instance: BrowsingUserUseCase(
                repository: DIContainer.shared.resolve(type: BrowsingUserRepository.self)
            )
        )

        DIContainer.shared.register(
            type: ConnectedUserUseCase.self,
            instance: ConnectedUserUseCase(
                repository: DIContainer.shared.resolve(type: ConnectedUserRepository.self)
            )
        )

        // MARK: - View Models

        DIContainer.shared.register(
            type: ConnectionViewModel.self,
            instance: ConnectionViewModel(
                usecase: DIContainer.shared.resolve(type: BrowsingUserUseCase.self)
            )
        )

        DIContainer.shared.register(
            type: GroupInfoViewModel.self,
            instance: GroupInfoViewModel()
        )

        DIContainer.shared.register(
            type: VideoListViewModel.self,
            instance: MockVideoListViewModel()
        )
    }
}
