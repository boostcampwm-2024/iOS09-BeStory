//
//  EditVideoElementSet.swift
//  Data
//
//  Created by jung on 12/3/24.
//

import Foundation

struct EditVideoElement: Codable, Hashable {
    let editingType: EditingType
    let url: URL
    let name: String
    let index: Int
    let editor: User
    let author: String
    let duration: Double
    let startTime: Double
    let endTime: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(editingType)
        hasher.combine(name)
    }
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
    /// 연결 보류 중인 경우(ex 백그라운드 이동하여 lost상태에서 `disConnected`되기 전 단계)
    case pending
}
