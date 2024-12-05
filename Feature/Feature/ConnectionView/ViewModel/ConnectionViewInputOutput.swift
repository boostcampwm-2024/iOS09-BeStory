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

// MARK: - Output

enum ConnectionViewOutput {
    // Connection Output

    case foundUser(user: BrowsedUser, position: CGPoint, emoji: String)
    case lostUser(user: BrowsedUser)

    // Invitation Output

    case invitationReceivedBy(user: BrowsedUser)
    case invitationAcceptedBy(user: InvitedUser)
    case connected(user: InvitedUser)
    case invitationRejectedBy(name: String)
    case invitationTimeout
    case openSharedVideoList
}
