//
//  BrowsingUserUseCaseInterface.swift
//  DomainInterface
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity

public protocol BrowsingUserUseCaseInterface {
	var browsedUser: PassthroughSubject<BrowsedUser, Never> { get }
	
	init(repository: BrowsingUserRepositoryInterface)
	
	func fetchBrowsedUsers() -> [BrowsedUser]
	func inviteUser(with id: String)
}
