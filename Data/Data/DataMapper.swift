//
//  DataMapper.swift
//  Data
//
//  Created by jung on 12/2/24.
//

import P2PSocket
import Entity

enum DataMapper {
	static func mappingToBrowsingUser(_ peer: SocketPeer) -> BrowsedUser? {
		switch peer.state {
			case .found:
				return .init(id: peer.id, state: .found, name: peer.name)
			case .lost:
				return .init(id: peer.id, state: .lost, name: peer.name)
			default: return nil
		}
	}
	
	static func mappingToInvitedUser(_ peer: SocketPeer) -> InvitedUser? {
		switch peer.state {
			case .connected:
				return .init(id: peer.id, state: .accept, name: peer.name)
			case .disconnected:
				return .init(id: peer.id, state: .reject, name: peer.name)
			default: return nil
		}
	}
	
	static func mappingToConnectedUser(_ peer: SocketPeer) -> ConnectedUser? {
		switch peer.state {
			case .connected:
				return .init(id: peer.id, state: .connected, name: peer.name)
			case .disconnected:
				return .init(id: peer.id, state: .disconnected, name: peer.name)
			case .pending:
				return .init(id: peer.id, state: .pending, name: peer.name)
			default:
				return nil
		}
	}
	
	static func mappingToSharedVideo(_ resource: SharedResource) -> SharedVideo? {
		guard let connectedUser = DataMapper.mappingToConnectedUser(resource.sender) else { return nil }
		
		return .init(localUrl: resource.url, author: connectedUser)
	}
}
