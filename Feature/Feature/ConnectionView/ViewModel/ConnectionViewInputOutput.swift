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
    case invite(id: String)

    // Invitation Input

    case accept
    case reject
}

// MARK: - Output

enum ConnectionViewOutput {
    // Connection Output

    case found(user: BrowsedUser, position: CGPoint, emoji: String)
    case lost(user: BrowsedUser, position: CGPoint)

    // Invitation Output

    case invited(from: BrowsedUser, position: CGPoint)
    case accepted(user: BrowsedUser, position: CGPoint)
    case rejected(name: String)
    case timeout
}
