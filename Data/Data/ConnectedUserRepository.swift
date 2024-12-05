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
	public typealias ConnectedUserSocketProvidable = SocketBrowsable & SocketDisconnectable

    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: ConnectedUserSocketProvidable

    public let updatedConnectedUser = PassthroughSubject<ConnectedUser, Never>()

    public init(socketProvider: ConnectedUserSocketProvidable) {
        self.socketProvider = socketProvider

        socketProvider.updatedPeer
            .compactMap { DataMapper.mappingToConnectedUser($0) }
            .subscribe(updatedConnectedUser)
            .store(in: &cancellables)
    }
}

// MARK: - Public Methods
public extension ConnectedUserRepository {
    func fetchConnectedUsers() -> [ConnectedUser] {
        return socketProvider.connectedPeers()
			.compactMap { DataMapper.mappingToConnectedUser($0) }
    }
    func leaveGroup() {
        socketProvider.disconnect()
    }
}
