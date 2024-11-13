//
//  ConnectionInputOutput.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Combine
import UIKit

enum ConnectionInput {
    case fetchUsers
    case invite(id: String)
}

enum ConnectionOutput {
    case none
    case found(user: BrowsingUser, position: CGPoint, emoji: String)
    case lost(user: BrowsingUser, position: CGPoint)
}
