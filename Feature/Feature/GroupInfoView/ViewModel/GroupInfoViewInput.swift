//
//  GroupInfoViewModelInput.swift
//  Feature
//
//  Created by Yune gim on 11/20/24.
//

import Foundation

// MARK: - Input

enum GroupInfoViewInput {
    case viewDidLoad
    case exitGroupButtonDidTab
}

// MARK: - Output

enum GroupInfoViewOutput {
    case userStateDidChanged(user: InvitedUser)
    case userDidInvited(user: InvitedUser)
    case groupCountDidChanged(count: Int)
    case titleDidChanged(title: String)
}
