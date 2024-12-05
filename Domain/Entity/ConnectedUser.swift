//
//  ConnectedUser.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

public struct ConnectedUser: Identifiable, Equatable {
	@frozen public enum State {
		/// 연결된 경우
        case connected
		/// 연결이 끊긴 경우
        case disconnected
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
