//
//  MockSocketProvider.swift
//  UseCaseTest
//
//  Created by jung on 11/7/24.
//

@testable import P2PSocket
import Combine
import Entity

final class MockSocketProvider: SocketProvidable {
	var mockPeers: [SocketPeer] = []
	let updatedPeer = PassthroughSubject<SocketPeer, Never>()
	
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
