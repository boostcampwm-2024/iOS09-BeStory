//
//  SharedVideo.swift
//  Entity
//
//  Created by Yune gim on 11/18/24.
//

import Foundation

public struct SharedVideo {
    public let localUrl: URL
    public let name: String
	public let author: String
    
    public init(
        localUrl: URL,
        name: String,
        author: String
    ) {
        self.localUrl = localUrl
        self.author = author
        self.name = name
    }
}
