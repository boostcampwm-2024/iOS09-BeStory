//
//  SocketPeer.swift
//  SocketProvider
//
//  Created by jung on 11/6/24.
//

public enum SocketPeerState {
	case connected
	case disconnected
	case found
	case lost
}

public struct SocketPeer {
	public let id: String
	public let name: String
	public var state: SocketPeerState
	
	public init(id: String, name: String, state: SocketPeerState) {
		self.id = id
		self.name = name
		self.state = state
	}
}
