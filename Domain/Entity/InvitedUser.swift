//
//  InvitedUser.swift
//  Entity
//
//  Created by jung on 11/14/24.
//

public struct InvitedUser: Identifiable {
	public enum State {
		case accept
		case reject
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
