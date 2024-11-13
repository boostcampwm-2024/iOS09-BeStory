//
//  ConnectedUser.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

public struct ConnectedUser: Identifiable {
    public enum State {
        case connected
        case disconnected
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
