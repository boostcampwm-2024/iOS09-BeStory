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
	private var connectedUsers: [ConnectedUser] = []
	private let repository: ConnectedUserRepositoryInterface
	
	public let updatedConnectedUser = PassthroughSubject<ConnectedUser, Never>()
	
	public init(repository: ConnectedUserRepositoryInterface) {
		self.repository = repository
		bind()
	}
}

// MARK: - Public Methods
public extension ConnectedUserUseCase {
	func fetchConnectedUser() -> [ConnectedUser] {
		self.connectedUsers = repository.fetchConnectedUsers()
		return connectedUsers
	}
}

// MARK: - Private Methods
private extension ConnectedUserUseCase {
	func bind() {
		repository.updatedConnectedUser
			.subscribe(updatedConnectedUser)
			.store(in: &cancellables)
	}
	
	func receivedUpdatedState(user: ConnectedUser) {
		switch user.state {
			case .connected:
				connectedUsers.append(user)
				updatedConnectedUser.send(user)
			case .pending:
				updatedConnectedUser.send(user)
			case .disconnected:
				guard let index = connectedUsers.firstIndex(of: user) else { return }
				connectedUsers.remove(at: index)
				updatedConnectedUser.send(user)
			default: break
		}
	}
}
