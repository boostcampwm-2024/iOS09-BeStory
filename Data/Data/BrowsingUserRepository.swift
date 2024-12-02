//
//  BrowsingUserRepository.swift
//  Data
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity
import Foundation
import Interfaces
import P2PSocket

public final class BrowsingUserRepository: BrowsingUserRepositoryInterface {
	public typealias BrowsingUserSocketProvidable = SocketBrowsable & SocketAdvertiseable & SocketInvitable
	
	private var cancellables: Set<AnyCancellable> = []
	private let socketProvider: BrowsingUserSocketProvidable
	public let updatedBrowsingUser = PassthroughSubject<BrowsedUser, Never>()
	public let updatedInvitedUser = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
    public let receivedEvent = PassthroughSubject<OpeningEvent, Never>()

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
    
    func notice(event: OpeningEvent) {
        let event = OpeningEvent.sharedContainer
        guard let eventData = try? JSONEncoder().encode(event) else { return }
        socketProvider.sendAll(data: eventData)
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
        
        socketProvider.dataShared
            .compactMap { (data, _) in
                try? JSONDecoder().decode(OpeningEvent.self, from: data)
            }.sink { [weak self] event in
                self?.receivedEvent.send(event)
            }.store(in: &cancellables)
	}
}
