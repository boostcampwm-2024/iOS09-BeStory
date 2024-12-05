//
//  BrowsingUserRepository.swift
//  Data
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity
import Foundation
import Interfaces
import P2PSocket

public final class BrowsingUserRepository: BrowsingUserRepositoryInterface {
    // swiftlint:disable line_length
    public typealias BrowsingUserSocketProvidable = SocketBrowsable & SocketAdvertiseable & SocketInvitable & SocketDataSendable
    // swiftlint:enable line_length
    
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: BrowsingUserSocketProvidable
    public let updatedBrowsingUser = PassthroughSubject<BrowsedUser, Never>()
    public let updatedInvitedUser = PassthroughSubject<InvitedUser, Never>()
    public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
    public let receivedEvent = PassthroughSubject<OpeningEvent, Never>()
    public let isInGroup: CurrentValueSubject<Bool, Never>
    
    public init(socketProvider: BrowsingUserSocketProvidable) {
        self.socketProvider = socketProvider
        self.isInGroup = socketProvider.isInGroup
        
        bind()
    }
}

// MARK: - Public Methods
public extension BrowsingUserRepository {
    func fetchBrowsingUsers() -> [BrowsedUser] {
        return socketProvider.browsingPeers()
            .compactMap { DataMapper.mappingToBrowsingUser($0) }
    }
    
    func startAdvertising() {
        socketProvider.startAdvertising()
    }
    
    func stopAdvertising() {
        socketProvider.stopAdvertising()
    }
    
    func inviteUser(with id: String, timeout: Double) {
        socketProvider.invite(peer: id, timeout: timeout)
    }
    
    func acceptInvitation() {
        socketProvider.acceptInvitation()
    }
    
    func rejectInvitation() {
        socketProvider.rejectInvitation()
    }
    
    func startReceiveInvitation() {
        socketProvider.startReceiveInvitation()
    }
    
    func stopReceiveInvitation() {
        socketProvider.stopReceiveInvitation()
    }
    
    func notice(event: OpeningEvent) {
        let event = OpeningEvent.sharedContainer
        guard let eventData = try? JSONEncoder().encode(event) else { return }
        socketProvider.broadcast(data: eventData)
    }
}

// MARK: - Private Methods
private extension BrowsingUserRepository {
    func bind() {
        socketProvider.updatedPeer
            .compactMap { DataMapper.mappingToBrowsingUser($0) }
            .subscribe(updatedBrowsingUser)
            .store(in: &cancellables)
        
        socketProvider.updatedPeer
            .compactMap { DataMapper.mappingToInvitedUser($0) }
            .subscribe(updatedInvitedUser)
            .store(in: &cancellables)
        
        socketProvider.invitationReceived
            .compactMap { DataMapper.mappingToBrowsingUser($0) }
            .subscribe(invitationReceived)
            .store(in: &cancellables)
        
        socketProvider.dataShared
            .compactMap { (data, _) in
                try? JSONDecoder().decode(OpeningEvent.self, from: data)
            }
            .sink(with: self) { owner, event in
                owner.receivedEvent.send(event)
            }.store(in: &cancellables)
    }
}
