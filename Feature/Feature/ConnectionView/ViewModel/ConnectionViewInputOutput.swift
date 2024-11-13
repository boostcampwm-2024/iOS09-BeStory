//
//  ConnectionInputOutput.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Entity

enum ConnectionInput {
    case fetchUsers
    case invite(id: String)
}

enum ConnectionOutput {
    case none
    case found(user: BrowsedUser, position: (Double, Double), emoji: String)
    case lost(user: BrowsedUser, position: (Double, Double))
}
