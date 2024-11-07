//
//  BrowsingUserRepositoryInterface.swift
//  DataInterface
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity

public protocol BrowsingUserRepositoryInterface {
	var updatedBrowsingUser: CurrentValueSubject<[BrowsingUser], Never> { get }
	
	func fetchBrowsingUsers() -> [BrowsingUser]
	func inviteUser(with id: String)
}
