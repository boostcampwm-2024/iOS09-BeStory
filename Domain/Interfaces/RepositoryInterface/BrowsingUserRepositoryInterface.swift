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
	var updatedBrowsingUser: PassthroughSubject<BrowsingUser, Never> { get }
	
	init(socketProvider: SocketProvidable)
	
	func fetchBrowsingUsers() -> [BrowsingUser]
	func inviteUser(with id: String)
}
