//
//  MockSocketProvider.swift
//  UseCaseTest
//
//  Created by jung on 11/7/24.
//

@testable import P2PSocket
import Combine
import Entity
import Foundation

final class MockSocketProvider: SocketProvidable {
	enum InvitationResultState {
		case accept
		case reject
		case timeout
	}
	
	// MARK: - Properties
	var invitationResultState: InvitationResultState = .accept
	let invitationReceived = PassthroughSubject<SocketPeer, Never>()
	var willReceiveInvitation: Bool = true
	var mockPeers: [SocketPeer] = []
	let updatedPeer = PassthroughSubject<SocketPeer, Never>()
	
	private var invitationTimer: Timer?
}

// MARK: - Browsing & Advertisting
extension MockSocketProvider {
	func browsingPeers() -> [SocketPeer] {
		return mockPeers
	}
	
	func connectedPeers() -> [SocketPeer] {
		return []
	}
	
	func startAdvertising() { }
	
	func stopAdvertising() { }
	
	func startBrowsing() { }
	
	func stopBrowsing() { }
}

// MARK: - Invitation
extension MockSocketProvider {
	func invite(peer id: String, timeout: Double) {
		let invitationPeer = invitedMockResult(id: id, state: invitationResultState)
		
		switch invitationResultState {
		case .accept, .reject:
			updatedPeer.send(invitationPeer)
		case .timeout:
			DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
				self?.updatedPeer.send(invitationPeer)
			}
		}
	}
	
	func acceptInvitation() { }
	
	func rejectInvitation() { }
	
	func startReceiveInvitation() { }
	
	func stopReceiveInvitation() { }
}

// MARK: - Private Methods
private extension MockSocketProvider {
	func invitedMockResult(id: String, state: InvitationResultState) -> SocketPeer {
		let state: SocketPeerState = state == .accept ? .connected : .disconnected
		
		return .init(id: id, name: "석영", state: state)
	}
}
