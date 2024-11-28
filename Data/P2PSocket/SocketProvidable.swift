//
//  SocketProvidable.swift
//  P2PSocket
//
//  Created by jung on 11/19/24.
//

import Combine
import Foundation

public protocol SocketProvidable:
    SocketInvitable, SocketBwrosable, SocketAdvertiseable, SocketDisconnectable,
    SocketResourceSendable, HashSynchronizable { }


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

public protocol SocketDisconnectable {
    func disconnectAllUser()
}


public protocol SocketResourceSendable {
	var resourceShared: PassthroughSubject<SharedResource, Never> { get }
	
    func shareResource(
        url localURL: URL,
        resourceName: String,
        to peerID: String,
        completion: (((any Error)?) -> Void)?
    )
	/// 연결된 모든 Peer들에게 리소스를 전송합니다.
    func shareResource(url: URL, resourceName: String) async throws
	/// Peer들과 공유한 모든 리소스를 리턴합니다.
	func sharedAllResources() -> [SharedResource]
}

public protocol HashSynchronizable {
    var isSynchronized: PassthroughSubject<Void, Never> { get }
    
    func sendHashes(_ hashes: [String: String])
}

