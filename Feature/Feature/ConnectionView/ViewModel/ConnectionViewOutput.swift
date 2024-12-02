//
//  ConnectionViewOutput.swift
//  Feature
//
//  Created by 이숲 on 12/2/24.
//

import Foundation
import Entity

// MARK: - Output

enum ConnectionViewOutput {
    // Connection Output

    case foundUser(user: BrowsedUser, position: CGPoint, emoji: String)
    case lostUser(user: BrowsedUser)

    // Invitation Output

    case invitationReceivedBy(user: BrowsedUser)
    case invitationAcceptedBy(user: BrowsedUser)
    case invitationRejectedBy(name: String)
    case invitationTimeout
    case openSharedVideoList
}
