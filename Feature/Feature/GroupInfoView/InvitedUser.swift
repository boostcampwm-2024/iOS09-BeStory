//
//  InvitedUser.swift
//  Domain
//
//  Created by Yune gim on 11/6/24.
//

import Foundation

public struct InvitedUser: Identifiable {
    public typealias ID = String
    public let id: ID
    public let name: String
    public var state: ConnectState
    
    public init(id: String, name: String, state: ConnectState) {
        self.id = id
        self.name = name
        self.state = state
    }
    
    public enum ConnectState {
        case connecting
        case connected
        case notConnected
    }
}

extension InvitedUser: Equatable { }
