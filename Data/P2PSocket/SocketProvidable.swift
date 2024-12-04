//
//  SocketProvidable.swift
//  P2PSocket
//
//  Created by jung on 11/19/24.
//

import Combine
import Foundation

// swiftlint:disable line_length
public typealias SocketProvidable =
SocketAdvertiseable & SocketBrowsable & SocketInvitable & SocketDisconnectable & SocketResourceSendable & SocketDataSendable
// swiftlint:enable line_length

public protocol SocketAdvertiseable: SocketIdentifiable {
    func startAdvertising()
    func stopAdvertising()
}

public protocol SocketBrowsable: SocketIdentifiable {
    var updatedPeer: PassthroughSubject<SocketPeer, Never> { get }
    /// Browsing된 Peer를 리턴합니다.
    func browsingPeers() -> [SocketPeer]
    /// Session에 연결된 Peer를 리턴합니다.
    func connectedPeers() -> [SocketPeer]
    
    func startBrowsing()
    func stopBrowsing()
}

public protocol SocketInvitable: SocketIdentifiable {
    var invitationReceived: PassthroughSubject<SocketPeer, Never> { get }
    
    /// 유저를 초대합니다.
    func invite(peer id: String, timeout: Double)
    
    func acceptInvitation()
    func rejectInvitation()
    
    func startReceiveInvitation()
    func stopReceiveInvitation()
}

public protocol SocketDisconnectable: SocketIdentifiable {
    func disconnect()
}

public protocol SocketResourceSendable: SocketIdentifiable {
    var resourceShared: PassthroughSubject<SharedResource, Never> { get }
    
    func unicastResource(
        url localURL: URL,
        resourceName: String,
        to peerID: String
    )
    /// 연결된 모든 Peer들에게 리소스를 전송합니다.
    func broadcastResource(url: URL, resourceName: String)
}

public protocol SocketDataSendable: SocketIdentifiable {
    var dataShared: PassthroughSubject<(Data, SocketPeer), Never> { get }
    
    func unicast(data: Data, to peerID: String)
    func broadcast(data: Data)
}

public protocol SocketIdentifiable {
    var displayName: String { get }
    var id: String { get }
}
