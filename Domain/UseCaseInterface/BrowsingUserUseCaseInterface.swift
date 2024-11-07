//
//  BrowsingUserUseCaseInterface.swift
//  DomainInterface
//
//  Created by jung on 11/7/24.
//

import Combine
import DataInterface
import Entity

public protocol BrowsingUserUseCaseInterface {
	var browsingUser: PassthroughSubject<BrowsingUser, Never> { get }
	
	init(repository: BrowsingUserRepositoryInterface)
	
	func fetchBrowsingUsers() -> [BrowsingUser]
	func inviteUser(with id: String)
}
