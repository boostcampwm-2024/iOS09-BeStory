//
//  SharedFile.swift
//  Entity
//
//  Created by Yune gim on 11/18/24.
//

import Foundation

public struct SharedResource {
    public let url: URL
    public let name: String
    public let owner: String
    public let sender: SocketPeer
    
    public init(
        url: URL,
        name: String,
        owner: String,
        sender: SocketPeer
    ) {
        self.url = url
        self.name = name
        self.owner = owner
        self.sender = sender
    }
}
