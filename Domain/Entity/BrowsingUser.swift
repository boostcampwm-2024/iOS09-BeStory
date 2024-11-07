//
//  BrowsingUser.swift
//  Entity
//
//  Created by jung on 11/7/24.
//

public struct BrowsingUser: Identifiable {
	public enum State {
		case lost
		case found
	}
	
	public let id: String
	public let state: State
	public let name: String
	
	public init(
		id: String,
		state: State,
		name: String
	) {
		self.id = id
		self.state = state
		self.name = name
	}
}
