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
	fileprivate enum Constants {
		static let invitationTimeout: Double = 30
	}
	
	private var isInvitating: Bool { invitationTimer != nil }
	private var invitationTimer: Timer?
	private var cancellables: Set<AnyCancellable> = []
	
	private let repository: BrowsingUserRepositoryInterface
	
	public let browsedUser = PassthroughSubject<BrowsedUser, Never>()
	public let invitationResult = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
	public let invitationDidFired = PassthroughSubject<Void, Never>()
	
	public init(repository: BrowsingUserRepositoryInterface) {
		self.repository = repository
		bind()
	}
}

// MARK: - Public Methods
public extension BrowsingUserUseCase {
	func fetchBrowsedUsers() -> [BrowsedUser] {
		return repository.fetchBrowsingUsers()
	}
	
	func inviteUser(with id: String) {
		repository.stopReceiveInvitation()
		repository.inviteUser(with: id, timeout: Constants.invitationTimeout)
	}
	
	func acceptInvitation(from id: String) {
		repository.startReceiveInvitation()
		repository.acceptInvitation(from: id)
	}
	
	func rejectInvitation(from id: String) {
		repository.startReceiveInvitation()
		repository.rejectInvitation(from: id)
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
		guard !isInvitating else {
			let convertStateInvitedUser = invitedUser.convertState(to: .alreadyInvited)
			return invitationResult.send(convertStateInvitedUser)
		}
		
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
			timeInterval: Constants.invitationTimeout,
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
