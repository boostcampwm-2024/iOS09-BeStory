//
//  ConnectedUser.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

public struct ConnectedUser: Identifiable {
    public enum State {
		/// 초대를 수락한 경우
        case connected
		
		/// 초대를 거절한 경우
        case disconnected
		
		/// 초대를 수락을 누른 경우
        case connecting
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
