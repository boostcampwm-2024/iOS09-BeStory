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
	
	private let repository: BrowsingUserRepositoryInterface
	private let invitationTimeout: Double
	
	public let browsedUser = PassthroughSubject<BrowsedUser, Never>()
	public let invitationResult = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
	public let invitationDidFired = PassthroughSubject<Void, Never>()
	
	public init(repository: BrowsingUserRepositoryInterface, invitationTimeout: Double = 30.0) {
		self.repository = repository
		self.invitationTimeout = invitationTimeout
		bind()
	}
}

// MARK: - Public Methods
public extension BrowsingUserUseCase {
	func fetchBrowsedUsers() -> [BrowsedUser] {
		return repository.fetchBrowsingUsers()
	}
	
	func inviteUser(with id: String) {
		invitationPeerID = id
		repository.stopReceiveInvitation()
		repository.inviteUser(with: id, timeout: invitationTimeout)
	}
	
	func acceptInvitation(from id: String) {
		repository.startReceiveInvitation()
		repository.acceptInvitation(from: id)
		stopInvitationTimer()
	}
	
	func rejectInvitation(from id: String) {
		repository.startReceiveInvitation()
		repository.rejectInvitation(from: id)
		stopInvitationTimer()
	}
}

// MARK: - Private Methods
private extension BrowsingUserUseCase {
	func bind() {
		repository.updatedBrowsingUser
			.subscribe(browsedUser)
			.store(in: &cancellables)
		
		repository.invitationReceived
			.subscribe(invitationReceived)
			.store(in: &cancellables)
		
		repository.updatedInvitedUser
			.sink { [weak self] invitedUser in
				self?.invitationResultDidReceive(with: invitedUser)
			}
			.store(in: &cancellables)
		
		repository.invitationReceived
			.sink { [weak self] _ in
				self?.invitationDidReceive()
			}
			.store(in: &cancellables)
	}
	
	func invitationResultDidReceive(with invitedUser: InvitedUser) {
		guard invitedUser.id == invitationPeerID else { return }
		
		repository.startReceiveInvitation()
		invitationResult.send(invitedUser)
	}
	
	func invitationDidReceive() {
		repository.stopReceiveInvitation()
		startInvitationTimer()
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
