//
//  SharedFile.swift
//  Entity
//
//  Created by Yune gim on 11/18/24.
//

import Foundation

public struct SharedResource {
    public let localUrl: URL
    public let name: String
    public let uuid: UUID
    public let sender: String
    
    public init(localUrl: URL, name: String, uuid: UUID, sender: String) {
        self.localUrl = localUrl
        self.name = name
        self.uuid = uuid
        self.sender = sender
    }
}

public enum ShareResourceError: Error {
    case peerFailedDownload(id: String)
}
