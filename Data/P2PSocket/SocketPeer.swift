//
//  SocketPeer.swift
//  SocketProvider
//
//  Created by jung on 11/6/24.
//

public enum SocketPeerState {
	case connected
	case disconnected
	case connecting
	case found
	case lost
}

public struct SocketPeer {
	public var state: SocketPeerState
	public let name: String
	public let id: String
}
