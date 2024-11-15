//
//  InvitedUser.swift
//  Entity
//
//  Created by jung on 11/14/24.
//

public struct InvitedUser: Identifiable {
	public enum State {
		/// 초대를 수락한 경우
		case accept
		/// 초대를 거절한 경우
		case reject
		/// 이미 다른 초대를 받는 중이거나, 보낸 경우
		case alreadyInvited
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
	
	public func convertState(to state: State) -> InvitedUser {
		return .init(id: id, state: state, name: name)
	}
}
