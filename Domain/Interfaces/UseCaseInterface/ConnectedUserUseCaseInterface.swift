//
//  ConnectedUserUseCaseInterface.swift
//  Domain
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Entity

public protocol ConnectedUserUseCaseInterface {
    var updatedConnectedUser: PassthroughSubject<ConnectedUser, Never> { get }

    init(repository: ConnectedUserRepositoryInterface)

    func fetchConnectedUsers() -> [ConnectedUser]
}
