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
    case fetchUsers
    case invite(id: String)
}

// MARK: - Output

enum ConnectionViewOutput {
    case none
    case found(user: BrowsedUser, position: (Double, Double), emoji: String)
    case lost(user: BrowsedUser, position: (Double, Double))
}
