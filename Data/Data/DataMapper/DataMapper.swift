//
//  DataMapper.swift
//  Data
//
//  Created by jung on 12/2/24.
//

import Core
import Entity
import P2PSocket

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
        return .init(
            localUrl: resource.url,
            name: resource.name,
            author: resource.owner
        )
	}

    static func mappingToEditVideoElement(_ video: Video, editor: String) -> EditVideoElement {
        let user = User(id: "-1", name: editor, state: .connected)
        
        return .init(
            url: video.url,
            name: video.name,
            index: video.index,
            editor: user,
            author: video.author,
            duration: video.duration,
            startTime: video.startTime,
            endTime: video.endTime
        )
    }
    
    static func mappingToVideo(_ element: EditVideoElement) -> Video? {
        guard let url = FileSystemManager.shared.mappingToLocalURL(url: element.url) else { return nil }

        let user = DataMapper.mappingToConnectedUser(element.editor)
        return .init(
            url: url,
            name: element.name,
            index: element.index,
            duration: element.duration,
            author: element.author,
            editor: user,
            startTime: element.startTime,
            endTime: element.endTime
        )
    }
    
    static func mappingToConnectedUser(_ user: User) -> ConnectedUser {
        switch user.state {
            case .connected:
                return .init(id: user.id, state: .connected, name: user.name)
            case .disconnected:
                return .init(id: user.id, state: .disconnected, name: user.name)
            case .pending:
                return .init(id: user.id, state: .pending, name: user.name)
        }
    }
    
    static func mappingToUser(_ peer: SocketPeer) -> User? {
        switch peer.state {
            case .connected:
                return .init(id: peer.id, name: peer.name, state: .connected)
            case .disconnected:
                return .init(id: peer.id, name: peer.name, state: .disconnected)
            case .pending:
                return .init(id: peer.id, name: peer.name, state: .pending)
            default: return nil
        }
    }
}
