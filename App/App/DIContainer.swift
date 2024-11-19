//
//  DIContainer.swift
//  App
//
//  Created by 이숲 on 11/19/24.
//

import Data
import Feature
import Interfaces
import P2PSocket
import UseCase

final class DIContainer {
    static let shared = DIContainer()

    private var services: [String: Any] = [:]

    func register<T>(type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }

    func resolve<T>(type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("\(key) is not registered.")
        }
        return service
    }

    func registerDependency() {
        registerP2PSocket()
        registerRepository()
        registerUseCase()
        registerViewModel()
    }
}

// MARK: - Dependency Register

private extension DIContainer {
    func registerP2PSocket() {
        DIContainer.shared.register(
            type: SocketProvidable.self,
            instance: SocketProvider()
        )
    }

    func registerRepository() {
        DIContainer.shared.register(
            type: BrowsingUserRepositoryInterface.self,
            instance: BrowsingUserRepository(socketProvider: DIContainer.shared.resolve(type: SocketProvidable.self))
        )

        DIContainer.shared.register(
            type: ConnectedUserRepositoryInterface.self,
            instance: ConnectedUserRepository(socketProvider: DIContainer.shared.resolve(type: SocketProvidable.self))
        )

        DIContainer.shared.register(
            type: SharingVideoRepositoryInterface.self,
            instance: SharingVideoRepository(socketProvider: DIContainer.shared.resolve(type: SocketProvidable.self))
        )

    }

    func registerUseCase() {
        DIContainer.shared.register(
            type: BrowsingUserUseCaseInterface.self,
            instance: BrowsingUserUseCase(repository: DIContainer.shared.resolve(type: BrowsingUserRepositoryInterface.self))
        )

        DIContainer.shared.register(
            type: ConnectedUserUseCaseInterface.self,
            instance: ConnectedUserUseCase(repository: DIContainer.shared.resolve(type: ConnectedUserRepositoryInterface.self))
        )
    }

    func registerViewModel() {
        DIContainer.shared.register(
            type: ConnectionViewModel.self,
            instance: ConnectionViewModel(usecase: DIContainer.shared.resolve(type: BrowsingUserUseCaseInterface.self))
        )

        DIContainer.shared.register(
            type: GroupInfoViewModel.self,
            instance: GroupInfoViewModel()
        )

        DIContainer.shared.register(
            type: MultipeerVideoListViewModel.self,
            instance: MultipeerVideoListViewModel()
        )
    }
}
