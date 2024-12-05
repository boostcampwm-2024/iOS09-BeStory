//
//  MCPeerIDMapper.swift
//  P2PSocket
//
//  Created by jung on 11/6/24.
//

import MultipeerConnectivity

final class MCPeerIDStorage {
	struct Peer {
		let peerId: MCPeerID
        let id: String
		var state: SocketPeerState
	}
	
	static let shared = MCPeerIDStorage()
	
	private(set) var peerIDByIdentifier: [String: Peer] = [:]
	
	private init() { }
}

// MARK: - Internal Methods
extension MCPeerIDStorage {
	@discardableResult
	/// peer를 append합니다. 리턴값은 ID 값입니다.
    func append(peerId: MCPeerID, id: String, state: SocketPeerState) -> String {
        peerIDByIdentifier[id] = .init(peerId: peerId, id: id, state: state)
		return id
	}
		
    @discardableResult
	/// `MCPeerID`의 유저를 삭제합니다.
    func remove(peerId: MCPeerID) -> Peer? {
        guard let peer = findPeer(for: peerId) else { return nil }
        return remove(peer.id)
	}
	
    @discardableResult
	/// `메모리 값`을 통해 유저를 삭제합니다.
	func remove(_ identifier: String) -> Peer? {
        defer { peerIDByIdentifier.removeValue(forKey: identifier) }
    
        return peerIDByIdentifier[identifier]
	}
	
	@discardableResult
	func update(state: SocketPeerState, id: MCPeerID) -> String? {
		guard let peer = findPeer(for: id) else { return nil }

		peerIDByIdentifier[peer.id]?.state = state
		return peer.id
	}
	
	/// `MCPeerID`를 통해 키와 값을 리턴합니다.
    func findPeer(for id: MCPeerID) -> Peer? {
		return peerIDByIdentifier
            .first { $0.value.peerId == id }?.value
	}
}
