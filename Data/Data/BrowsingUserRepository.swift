//
//  BrowsingUserRepository.swift
//  Data
//
//  Created by jung on 11/7/24.
//

import Combine
import DataInterface
import Interfaces
import Entity

public final class BrowsingUserRepository: BrowsingUserRepositoryInterface {
	private var cancellables: Set<AnyCancellable> = []
	private let socketProvider: SocketProvidable
	public let updatedBrowsingUser = PassthroughSubject<BrowsedUser, Never>()

	public init(socketProvider: SocketProvidable) {
		self.socketProvider = socketProvider
		
		socketProvider.updatedPeer
            .compactMap { [weak self] peer in
				self?.mappingToBrowsingUser(peer) }
			.subscribe(updatedBrowsingUser)
			.store(in: &cancellables)
	}
}

// MARK: - Public Methods
public extension BrowsingUserRepository {
	func fetchBrowsingUsers() -> [BrowsedUser] {
		return socketProvider.browsingPeers()
			.compactMap { mappingToBrowsingUser($0) }
	}
	
	func inviteUser(with id: String) { }
}

// MARK: - Private Methods
private extension BrowsingUserRepository {
	func mappingToBrowsingUser(_ peer: SocketPeer) -> BrowsedUser? {
		switch peer.state {
			case .found:
				return .init(id: peer.id, state: .found, name: peer.name)
			case .lost:
				return .init(id: peer.id, state: .lost, name: peer.name)
			default: return nil
		}
	}
}
