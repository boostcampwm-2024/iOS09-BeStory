//
//  BrowsingUserRepository.swift
//  Data
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity
import Interfaces
import P2PSocket

public final class BrowsingUserRepository: BrowsingUserRepositoryInterface {
	public typealias BrowsingUserSocketProvidable = SocketBrowsable & SocketAdvertiseable & SocketInvitable
	
	private var cancellables: Set<AnyCancellable> = []
	private let socketProvider: BrowsingUserSocketProvidable
	public let updatedBrowsingUser = PassthroughSubject<BrowsedUser, Never>()
	public let updatedInvitedUser = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()

	public init(socketProvider: BrowsingUserSocketProvidable) {
		self.socketProvider = socketProvider
		
		bind()
	}
}

// MARK: - Public Methods
public extension BrowsingUserRepository {
	func fetchBrowsingUsers() -> [BrowsedUser] {
		return socketProvider.browsingPeers()
			.compactMap { DataMapper.mappingToBrowsingUser($0) }
	}
	
	func inviteUser(with id: String, timeout: Double) {
		socketProvider.invite(peer: id, timeout: timeout)
	}
	
	func acceptInvitation() {
		socketProvider.acceptInvitation()
	}
	
	func rejectInvitation() {
		socketProvider.rejectInvitation()
	}
	
	func startReceiveInvitation() {
		socketProvider.startReceiveInvitation()
	}
	
	func stopReceiveInvitation() {
		socketProvider.stopReceiveInvitation()
	}
}

// MARK: - Private Methods
private extension BrowsingUserRepository {
	func bind() {
		socketProvider.updatedPeer
			.compactMap { peer in
				DataMapper.mappingToBrowsingUser(peer)
			}
			.subscribe(updatedBrowsingUser)
			.store(in: &cancellables)
		
		socketProvider.updatedPeer
			.compactMap { peer in
				DataMapper.mappingToInvitedUser(peer)
			}
			.subscribe(updatedInvitedUser)
			.store(in: &cancellables)
		
		socketProvider.invitationReceived
			.compactMap { peer in
				DataMapper.mappingToBrowsingUser(peer)
			}
			.subscribe(invitationReceived)
			.store(in: &cancellables)
	}
}
