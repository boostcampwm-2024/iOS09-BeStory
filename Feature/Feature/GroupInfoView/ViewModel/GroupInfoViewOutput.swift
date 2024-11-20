//
//  GroupInfoViewOutput.swift
//  Feature
//
//  Created by Yune gim on 11/20/24.
//

import Entity

// MARK: - Output

enum GroupInfoViewOutput {
    case userStateDidChanged(user: ConnectedUser)
    case userDidInvited(user: ConnectedUser)
    case userDidExit(user: ConnectedUser)
    case groupCountDidChanged(count: Int)
    case titleDidChanged(title: String)
}
