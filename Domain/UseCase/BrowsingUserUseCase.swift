//
//  BrowsingUserUseCase.swift
//  Domain
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity
import Foundation
import Interfaces

public final class BrowsingUserUseCase: BrowsingUserUseCaseInterface {
	private var isInvitating: Bool { invitationTimer != nil }
	private var invitationTimer: Timer?
	private var cancellables: Set<AnyCancellable> = []
	private var invitationPeerID: String?
	private var browsedUsersID: [String] = []
	
	private let repository: BrowsingUserRepositoryInterface
	private let invitationTimeout: Double
	
	public let browsedUser = PassthroughSubject<BrowsedUser, Never>()
	public let invitationResult = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
	public let invitationDidFired = PassthroughSubject<Void, Never>()
    public var openingEvent = PassthroughSubject<Void, Never>()
	
	public init(repository: BrowsingUserRepositoryInterface, invitationTimeout: Double = 30.0) {
		self.repository = repository
		self.invitationTimeout = invitationTimeout
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
		invitationPeerID = id
		repository.stopReceiveInvitation()
		repository.inviteUser(with: id, timeout: invitationTimeout)
	}
	
	func acceptInvitation() {
		stopInvitationTimer()
		repository.startReceiveInvitation()
		repository.acceptInvitation()
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
			.sink { [weak self] user in
				self?.receivedBrowsedUser(user)
			}
			.store(in: &cancellables)
		
		repository.updatedInvitedUser
			.sink { [weak self] invitedUser in
				self?.invitationResultDidReceive(with: invitedUser)
			}
			.store(in: &cancellables)
		
		repository.invitationReceived
			.sink { [weak self] user in
				self?.invitationDidReceive(from: user)
			}
			.store(in: &cancellables)
        repository.receivedEvent
            .sink { [weak self] event in
                guard event == .sharedContainer else { return }
                self?.openingEvent.send()
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
		guard invitedUser.id == invitationPeerID else { return }
		invitationPeerID = nil
		repository.startReceiveInvitation()
		invitationResult.send(invitedUser)
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
