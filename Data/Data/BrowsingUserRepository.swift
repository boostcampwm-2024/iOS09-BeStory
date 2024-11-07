//
//  BrowsingUserRepository.swift
//  Data
//
//  Created by jung on 11/7/24.
//

import Combine
import DataInterface
import Entity
import P2PSocket

public final class BrowsingUserRepository: BrowsingUserRepositoryInterface {
	private var cancellables: Set<AnyCancellable> = []
	private let socketProvider: SocketProvider
	public let updatedBrowsingUser = CurrentValueSubject<[BrowsingUser], Never>([])
	
	public init(socket: SocketProvider) {
		self.socketProvider = socket
		
		socketProvider.updatedPeers
			.map { [weak self] peers in
				peers.compactMap { self?.mappingToBrowsingUser($0) } }
			.subscribe(updatedBrowsingUser)
			.store(in: &cancellables)
	}
}

// MARK: - Public Methods
public extension BrowsingUserRepository {
	func fetchBrowsingUsers() -> [BrowsingUser] {
		return socketProvider.browsingPeers()
			.compactMap { mappingToBrowsingUser($0) }
	}
	
	func inviteUser(with id: String) { }
}

// MARK: - Private Methods
private extension BrowsingUserRepository {
	func mappingToBrowsingUser(_ peer: SocketPeer) -> BrowsingUser? {
		switch peer.state {
			case .found:
				return .init(id: peer.id, state: .found, name: peer.name)
			case .lost:
				return .init(id: peer.id, state: .lost, name: peer.name)
			default: return nil
		}
	}
}
