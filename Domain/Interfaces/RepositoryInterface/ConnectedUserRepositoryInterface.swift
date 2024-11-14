//
//  ConnectedUserRepositoryInterface.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import DataInterface
import Entity

public protocol ConnectedUserRepositoryInterface {
    var updatedConnectedUser: PassthroughSubject<ConnectedUser, Never> { get }

    init(socketProvider: SocketProvidable)

    func fetchConnectedUsers() -> [ConnectedUser]
}
