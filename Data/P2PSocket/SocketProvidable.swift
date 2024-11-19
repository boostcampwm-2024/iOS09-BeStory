//
//  SocketProvidable.swift
//  P2PSocket
//
//  Created by jung on 11/19/24.
//

import Combine

public protocol SocketProvidable: SocketInvitable, SocketBwrosable, SocketAdvertiseable { }

public protocol SocketAdvertiseable {
	func startAdvertising()
	func stopAdvertising()
}

public protocol SocketBwrosable {
	var updatedPeer: PassthroughSubject<SocketPeer, Never> { get }
	/// Browsing된 Peer를 리턴합니다.
	func browsingPeers() -> [SocketPeer]
	
	func startBrowsing()
	func stopBrowsing()
	
	/// Session에 연결된 Peer를 리턴합니다.
	func connectedPeers() -> [SocketPeer]
}

public protocol SocketInvitable {
	var invitationReceived: PassthroughSubject<SocketPeer, Never> { get }

	/// 유저를 초대합니다.
	func invite(peer id: String, timeout: Double)
	
	func acceptInvitation()
	func rejectInvitation()
	
	func startReceiveInvitation()
	func stopReceiveInvitation()
}
