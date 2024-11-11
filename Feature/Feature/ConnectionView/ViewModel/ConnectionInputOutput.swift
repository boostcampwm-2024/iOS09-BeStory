//
//  ConnectionInputOutput.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Combine

enum ConnectionInput {
    case fetchUsers
    case invite(id: String)
}

enum ConnectionOutput {
    case none
    case fetched(_ users: [BrowsingUser])
    case updated(_ user: BrowsingUser)
}
