//
//  MockBrowsingUserRepository.swift
//  UseCaseTest
//
//  Created by jung on 11/7/24.
//

@testable import Interfaces
import Combine
import Entity
import P2PSocket

final class MockBrowsingUserRepository: BrowsingUserRepositoryInterface {
	private let socketProvider: SocketProvidable
	private var cancellables: Set<AnyCancellable> = []
	let updatedBrowsingUser = PassthroughSubject<BrowsedUser, Never>()
	
	init(socketProvider: SocketProvidable) {
		self.socketProvider = socketProvider
		
		socketProvider.updatedPeer
			.compactMap { [weak self] peer in
				self?.mappingToBrowsingUser(peer) }
			.subscribe(updatedBrowsingUser)
			.store(in: &cancellables)
	}
	
	func fetchBrowsingUsers() -> [BrowsedUser] {
		return socketProvider.browsingPeers()
			.compactMap { mappingToBrowsingUser($0) }
	}
	
	func inviteUser(with id: String) { }
}

// MARK: - Private Methods
private extension MockBrowsingUserRepository {
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
