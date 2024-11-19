//
//  ConnectedUserRepository.swift
//  Data
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Entity
import Interfaces
import P2PSocket

public final class ConnectedUserRepository: ConnectedUserRepositoryInterface {
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: SocketProvidable

    public let updatedConnectedUser = PassthroughSubject<ConnectedUser, Never>()

    public init(socketProvider: SocketProvidable) {
        self.socketProvider = socketProvider

        socketProvider.updatedPeer
            .compactMap({ [weak self] peer in
                self?.mappingToConnectedUser(peer) })
            .subscribe(updatedConnectedUser)
            .store(in: &cancellables)
    }
}

// MARK: - Public Methods

public extension ConnectedUserRepository {
    func fetchConnectedUsers() -> [ConnectedUser] {
        return socketProvider.connectedPeers()
            .compactMap({ mappingToConnectedUser($0) })
    }
}

// MARK: - Private Methods

private extension ConnectedUserRepository {
    func mappingToConnectedUser(_ peer: SocketPeer) -> ConnectedUser? {
        switch peer.state {
        case .connected:
            return .init(id: peer.id, state: .connected, name: peer.name)
        case .disconnected:
            return .init(id: peer.id, state: .disconnected, name: peer.name)
		case .pending:
			return .init(id: peer.id, state: .pending, name: peer.name)
        default:
            return nil
        }
    }
}
