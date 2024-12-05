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
        let socketProvider = DIContainer.shared.resolve(type: SocketProvidable.self)
        
        DIContainer.shared.register(
            type: BrowsingUserRepositoryInterface.self,
            instance: BrowsingUserRepository(socketProvider:socketProvider)
        )

        DIContainer.shared.register(
            type: ConnectedUserRepositoryInterface.self,
            instance: ConnectedUserRepository(socketProvider: socketProvider)
        )

        DIContainer.shared.register(
            type: SharingVideoRepositoryInterface.self,
            instance: SharingVideoRepository(socketProvider: socketProvider)
        )
        
        DIContainer.shared.register(
            type: EditVideoRepositoryInterface.self,
            instance: EditVideoRepository(socketProvider: socketProvider)
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
        
        DIContainer.shared.register(
            type: SharingVideoUseCaseInterface.self,
            instance: VideoUseCase(
                sharingVideoRepository: DIContainer.shared.resolve(type: SharingVideoRepositoryInterface.self),
                editVideoRepository: DIContainer.shared.resolve(type: EditVideoRepositoryInterface.self)
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
            type: MultipeerVideoListViewModel.self,
            instance: MultipeerVideoListViewModel(
                usecase: DIContainer.shared.resolve(type: SharingVideoUseCaseInterface.self)
            )
        )

        DIContainer.shared.register(
            type: SharedVideoEditViewModel.self,
            instance: SharedVideoEditViewModel(
                usecase: DIContainer.shared.resolve(type: VideoUseCaseInterface.self) as! EditVideoUseCaseInterface
            )
        )
    }
}
