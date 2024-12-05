//
//  BrowsingUserUseCase.swift
//  Domain
//
//  Created by jung on 11/7/24.
//

import Combine
import Core
import Entity
import Foundation
import Interfaces

public final class BrowsingUserUseCase: BrowsingUserUseCaseInterface {
    private var isInvitating: Bool { invitationTimer != nil }
    /// 초대를 보낸 유저의 ID입니다.
    private var invitationUserID: String?
    private var invitationTimer: Timer?
    private var cancellables: Set<AnyCancellable> = []
    private var browsedUsersID: [String] = []
    
    private let repository: BrowsingUserRepositoryInterface
    private let invitationTimeout: Double
    
    public let browsedUser = PassthroughSubject<BrowsedUser, Never>()
    public let isInGroup: CurrentValueSubject<Bool, Never>
    public let invitationResult = PassthroughSubject<InvitedUser, Never>()
    public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
    public let invitationDidFired = PassthroughSubject<Void, Never>()
    public let connectedUser = PassthroughSubject<InvitedUser, Never>()
    public let openingEvent = PassthroughSubject<Void, Never>()
    
    public init(repository: BrowsingUserRepositoryInterface, invitationTimeout: Double = 30.0) {
        self.repository = repository
        self.invitationTimeout = invitationTimeout
        self.isInGroup = repository.isInGroup
        bind()
    }
}

// MARK: - Public Methods
public extension BrowsingUserUseCase {
    func fetchBrowsedUsers() -> [BrowsedUser] {
        let browsedUsers = repository.fetchBrowsingUsers()
        self.browsedUsersID = browsedUsers.map { $0.id }
        return browsedUsers
    }
    
    func inviteUser(with id: String) {
        invitationUserID = id
        repository.stopReceiveInvitation()
        repository.inviteUser(with: id, timeout: invitationTimeout)
    }
    
    func acceptInvitation() {
        stopInvitationTimer()
        repository.startReceiveInvitation()
        repository.acceptInvitation()
    }
    
    func startAdvertising() {
        repository.startAdvertising()
    }
    
    func stopAdvertising() {
        repository.stopAdvertising()
    }
    
    func rejectInvitation() {
        stopInvitationTimer()
        repository.startReceiveInvitation()
        repository.rejectInvitation()
    }
    
    func noticeOpening() {
        repository.notice(event: OpeningEvent.sharedContainer)
        openingEvent.send()
    }
}

// MARK: - Private Methods
private extension BrowsingUserUseCase {
    func bind() {
        repository.updatedBrowsingUser
            .sink(with: self) { owner, user in
                owner.receivedBrowsedUser(user)
            }
            .store(in: &cancellables)
        
        repository.updatedInvitedUser
            .sink(with: self) { owner, invitedUser in
                owner.invitationResultDidReceive(with: invitedUser)
            }
            .store(in: &cancellables)
        
        repository.invitationReceived
            .sink(with: self) { owner, user in
                owner.invitationDidReceive(from: user)
            }
            .store(in: &cancellables)
        
        repository.receivedEvent
            .sink(with: self) { owner, event in
                guard event == .sharedContainer else { return }
                owner.openingEvent.send()
            }
            .store(in: &cancellables)
    }
    
    func receivedBrowsedUser(_ user: BrowsedUser) {
        switch user.state {
            case .found:
                guard !browsedUsersID.contains(user.id) else { return }
                browsedUsersID.append(user.id)
            case .lost:
                guard let index = browsedUsersID.firstIndex(where: { $0 == user.id }) else { return }
                browsedUsersID.remove(at: index)
        }
        self.browsedUser.send(user)
    }

    func invitationResultDidReceive(with invitedUser: InvitedUser) {
        guard invitationUserID == invitedUser.id else {
            return connectedUserDidReceive(invitedUser)
        }
        invitationUserID = nil

        repository.startReceiveInvitation()
        switch invitedUser.state {
            case .accept:
                invitationResult.send(invitedUser)
                guard let index = browsedUsersID.firstIndex(where: { $0 == invitedUser.id }) else { return }
                browsedUsersID.remove(at: index)
            case .reject where browsedUsersID.contains(invitedUser.id):
                invitationResult.send(invitedUser)
            default: break
        }
    }
    
    func connectedUserDidReceive(_ user: InvitedUser) {
        guard user.state == .accept else { return }
        connectedUser.send(user)
    }
    
    func invitationDidReceive(from user: BrowsedUser) {
        repository.stopReceiveInvitation()
        startInvitationTimer()
        invitationReceived.send(user)
    }
    
    func startInvitationTimer() {
        invitationTimer?.invalidate()
        invitationTimer = Timer.scheduledTimer(
            timeInterval: invitationTimeout,
            target: self,
            selector: #selector(invitationTimerDidFired),
            userInfo: nil,
            repeats: false
        )
    }
    
    func stopInvitationTimer() {
        invitationTimer?.invalidate()
        invitationTimer = nil
    }
    
    @objc func invitationTimerDidFired() {
        invitationDidFired.send(())
        stopInvitationTimer()
        repository.startReceiveInvitation()
    }
}
