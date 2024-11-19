//
//  ConnectionViewInputOutput.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Entity

// MARK: - Input

enum ConnectionViewInput {
    // Connection Input

    case fetchUsers
    case invite(id: String)

    // Invitation Input

    case accept(id: String)
    case reject(id: String)
}

// MARK: - Output

enum ConnectionViewOutput {
    // Connection Output

    case found(user: BrowsedUser, position: (Double, Double), emoji: String)
    case lost(user: BrowsedUser, position: (Double, Double))

    // Invitation Output

    case invited(from: BrowsedUser)
    case accepted(name: String)
    case rejected(name: String)
    case timeout
}
