//
//  SharedVideo.swift
//  Entity
//
//  Created by Yune gim on 11/18/24.
//

import Foundation

public struct SharedVideo {
    public let localUrl: URL
	public let author: String
    
    public init(localUrl: URL, author: String) {
        self.localUrl = localUrl
        self.author = author
    }
}
