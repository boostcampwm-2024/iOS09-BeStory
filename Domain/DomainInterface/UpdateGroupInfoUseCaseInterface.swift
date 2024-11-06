//
//  File.swift
//  DomainInterface
//
//  Created by Yune gim on 11/7/24.
//

import Combine

public protocol UpdateGroupInfoUseCaseInterface {
    var invitedUser: PassthroughSubject<InvitedUser, Never> { get }
    var updatedUser: PassthroughSubject<InvitedUser, Never> { get }
    var updatedTitle: CurrentValueSubject<String, Never> { get }
}
