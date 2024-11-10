//
//  BrowsingUserRepositoryInterface.swift
//  DataInterface
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity
import P2PSocket

public protocol BrowsingUserRepositoryInterface {
	var updatedBrowsingUser: PassthroughSubject<BrowsedUser, Never> { get }
	
	init(socketProvider: SocketProvidable)
	
	func fetchBrowsingUsers() -> [BrowsedUser]
	func inviteUser(with id: String)
}
