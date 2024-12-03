//
//  Video.swift
//  Entity
//
//  Created by jung on 12/2/24.
//

import Foundation

public struct Video {
    public let url: URL
    public let name: String
    public let index: Int
    public let author: String
    public let editor: ConnectedUser?
    public let duration: Double
    public let startTime: Double
    public let endTime: Double
    
    public init(
        url: URL,
        name: String,
        index: Int,
        duration: Double,
        author: String,
        editor: ConnectedUser,
        startTime: Double,
        endTime: Double
    ) {
        self.url = url
        self.name = name
        self.index = index
        self.author = author
        self.editor = editor
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public init(
        url: URL,
        name: String,
        index: Int,
        author: String,
        duration: Double
    ) {
        self.url = url
        self.name = name
        self.index = index
        self.author = author
        self.duration = duration
        self.startTime = 0
        self.endTime = duration
        self.editor = nil
    }
}
