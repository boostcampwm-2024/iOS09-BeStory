//
//  ConnectionViewInputOutput.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Foundation
import Entity

// MARK: - Input

enum ConnectionViewInput {
    // Connection Input

    case fetchUsers
    case inviteUser(id: String)

    // Invitation Input

    case acceptInvitation(user: BrowsedUser)
    case rejectInvitation
    case nextButtonDidTapped
}
