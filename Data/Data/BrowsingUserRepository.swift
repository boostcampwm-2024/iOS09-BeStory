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
	private var cancellables: Set<AnyCancellable> = []
	private let socketProvider: SocketProvidable
	public let updatedBrowsingUser = PassthroughSubject<BrowsedUser, Never>()
	public let updatedInvitedUser = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
    public let receivedEvent = PassthroughSubject<OpeningEvent, Never>()

	public init(socketProvider: SocketProvidable) {
		self.socketProvider = socketProvider
		
		bind()
	}
}

// MARK: - Public Methods
public extension BrowsingUserRepository {
	func fetchBrowsingUsers() -> [BrowsedUser] {
		return socketProvider.browsingPeers()
			.compactMap { mappingToBrowsingUser($0) }
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
			.compactMap { [weak self] peer in
				self?.mappingToBrowsingUser(peer)
			}
			.subscribe(updatedBrowsingUser)
			.store(in: &cancellables)
		
		socketProvider.updatedPeer
			.compactMap { [weak self] peer in
				self?.mappingToInvitedUser(peer)
			}
			.subscribe(updatedInvitedUser)
			.store(in: &cancellables)
		
		socketProvider.invitationReceived
			.compactMap { [weak self] peer in
				self?.mappingToBrowsingUser(peer)
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
	
	func mappingToBrowsingUser(_ peer: SocketPeer) -> BrowsedUser? {
		switch peer.state {
			case .found:
				return .init(id: peer.id, state: .found, name: peer.name)
			case .lost:
				return .init(id: peer.id, state: .lost, name: peer.name)
			default: return nil
		}
	}
	
	func mappingToInvitedUser(_ peer: SocketPeer) -> InvitedUser? {
		switch peer.state {
			case .connected:
				return .init(id: peer.id, state: .accept, name: peer.name)
			case .disconnected:
				return .init(id: peer.id, state: .reject, name: peer.name)
			default: return nil
		}
	}
}
