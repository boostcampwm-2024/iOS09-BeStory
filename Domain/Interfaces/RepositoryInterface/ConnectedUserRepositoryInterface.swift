//
//  ConnectedUserRepositoryInterface.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Entity

public protocol ConnectedUserRepositoryInterface {
    var updatedConnectedUser: PassthroughSubject<ConnectedUser, Never> { get }

    func fetchConnectedUsers() -> [ConnectedUser]
    func leaveGroup()
}
