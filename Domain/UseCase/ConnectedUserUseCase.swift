//
//  ConnectedUserUseCase.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Interfaces
import Entity

public final class ConnectedUserUseCase: ConnectedUserUseCaseInterface {
    private var cancellables: Set<AnyCancellable> = []
    private let repository: ConnectedUserRepositoryInterface

    public let connectedUser = PassthroughSubject<ConnectedUser, Never>()

    public init(repository: ConnectedUserRepositoryInterface) {
        self.repository = repository
        bind()
    }
}

// MARK: - Public Methods

public extension ConnectedUserUseCase {
    func fetchConnectedUsers() -> [ConnectedUser] {
        return repository.fetchConnectedUsers()
    }
}

// MARK: - Private Methods

private extension ConnectedUserUseCase {
    func bind() {
        repository.updatedConnectedUser
            .subscribe(connectedUser)
            .store(in: &cancellables)
    }
}
