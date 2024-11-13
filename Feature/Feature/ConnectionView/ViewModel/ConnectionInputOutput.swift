//
//  ConnectionInputOutput.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import Entity
import UIKit

enum ConnectionInput {
    case fetchUsers
    case invite(id: String)
}

enum ConnectionOutput {
    case none
    case found(user: BrowsedUser, position: CGPoint, emoji: String)
    case lost(user: BrowsedUser, position: CGPoint)
}
