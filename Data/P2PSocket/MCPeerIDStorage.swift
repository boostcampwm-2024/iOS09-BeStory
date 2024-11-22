//
//  MCPeerIDMapper.swift
//  P2PSocket
//
//  Created by jung on 11/6/24.
//

import MultipeerConnectivity

final class MCPeerIDStorage {
	struct Peer {
		let id: MCPeerID
		var state: SocketPeerState
	}
	
	static let shared = MCPeerIDStorage()
	
	private(set) var peerIDByIdentifier: [String: Peer] = [:]
	
	private init() { }
}

// MARK: - Internal Methods
extension MCPeerIDStorage {
	@discardableResult
	/// peer를 append합니다. 리턴값은 메모리 값입니다.
	func append(id: MCPeerID, state: SocketPeerState) -> String {
		let identifier = identifier(for: id)
		peerIDByIdentifier[identifier] = .init(id: id, state: state)
		return identifier
	}
		
	/// `MCPeerID`의 유저를 삭제합니다.
	func remove(id: MCPeerID) {
		guard let peer = findPeer(for: id) else { return }
		remove(peer.key)
	}
	
	/// `메모리 값`을 통해 유저를 삭제합니다. 
	func remove(_ identifier: String) {
		peerIDByIdentifier.removeValue(forKey: identifier)
	}
	
	@discardableResult
	func update(state: SocketPeerState, id: MCPeerID) -> String? {
		guard let peer = findPeer(for: id) else { return nil }

		peerIDByIdentifier[peer.key]?.state = state
		return peer.key
	}
	
	/// `MCPeerID`를 통해 키와 값을 리턴합니다.
	func findPeer(for id: MCPeerID) -> Dictionary<String, Peer>.Element? {
		return peerIDByIdentifier
			.first { $0.value.id == id }
	}
}

// MARK: - Private Methods
private extension MCPeerIDStorage {
	/// 메모리 주소를 identifier로 리턴합니다.
	func identifier(for peerID: MCPeerID) -> String {
		let address = Unmanaged.passUnretained(peerID).toOpaque()
		return String(describing: address)
	}
}
