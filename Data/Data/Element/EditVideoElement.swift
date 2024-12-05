//
//  EditVideoElementSet.swift
//  Data
//
//  Created by jung on 12/3/24.
//

import Foundation

struct EditVideoElement: Codable, Hashable {
    let url: URL
    let name: String
    let index: Int
    let editor: User
    let author: String
    let duration: Double
    let startTime: Double
    let endTime: Double

    func hash(into hasher: inout Hasher) {
//        hasher.combine(url.lastPathComponent)
        hasher.combine(name)
    }

    static func == (lhs: EditVideoElement, rhs: EditVideoElement) -> Bool {
        return lhs.name == rhs.name
    }
    // lhs.url.lastPathComponent == rhs.url.lastPathComponent &&
}

struct User: Codable, Hashable {
    let id: String
    let name: String
    let state: ConnectionState
}

enum ConnectionState: Codable {
    /// 연결된 경우
    case connected
    /// 연결이 끊긴 경우
    case disconnected
}
