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
	private var connectedUsersID: [String] = []
	private let repository: ConnectedUserRepositoryInterface
	
	public let updatedConnectedUser = PassthroughSubject<ConnectedUser, Never>()
	
	public init(repository: ConnectedUserRepositoryInterface) {
		self.repository = repository
		bind()
	}
}

// MARK: - Public Methods
public extension ConnectedUserUseCase {
	func fetchConnectedUsers() -> [ConnectedUser] {
		let connectedUsers = repository.fetchConnectedUsers()
		connectedUsersID = connectedUsers.map { $0.id }
		return connectedUsers
	}
    
    func leaveGroup() {
        repository.leaveGroup()
        
    }
}

// MARK: - Private Methods
private extension ConnectedUserUseCase {
	func bind() {
		repository.updatedConnectedUser
			.sink { [weak self] user in
				self?.receivedUpdatedState(user: user)
			}
			.store(in: &cancellables)
	}
	
	func receivedUpdatedState(user: ConnectedUser) {
		switch user.state {
			case .connected:
				connectedUsersID.append(user.id)
				updatedConnectedUser.send(user)
			case .pending:
				updatedConnectedUser.send(user)
			case .disconnected:
				guard let index = connectedUsersID.firstIndex(where: { $0 == user.id }) else { return }
				connectedUsersID.remove(at: index)
				updatedConnectedUser.send(user)
		}
	}
}
