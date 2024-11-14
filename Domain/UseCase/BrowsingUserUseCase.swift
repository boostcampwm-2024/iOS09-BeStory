//
//  BrowsingUserUseCase.swift
//  Domain
//
//  Created by jung on 11/7/24.
//

import Combine
import Interfaces
import Entity

public final class BrowsingUserUseCase: BrowsingUserUseCaseInterface {
	private var cancellables: Set<AnyCancellable> = []
	private var isInviting: Bool = false {
		didSet {
			isInviting ? repository.stopReceiveInvitation() : repository.startReceiveInvitation()
		}
	}
	
	private let repository: BrowsingUserRepositoryInterface
	
	public let browsedUser = PassthroughSubject<BrowsedUser, Never>()
	public let invitationResult = PassthroughSubject<InvitedUser, Never>()
	public let invitationReceived = PassthroughSubject<BrowsedUser, Never>()
	
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
		isInviting = true
		repository.inviteUser(with: id)
	}
	
	func acceptInvitation(from id: String) {
		isInviting = false
		repository.acceptInvitation(from: id)
	}
	
	func rejectInvitation(from id: String) {
		isInviting = false
		repository.rejectInvitation(from: id)
	}
}

// MARK: - Private Methods
private extension BrowsingUserUseCase {
	func bind() {
		repository.updatedBrowsingUser
			.subscribe(browsedUser)
			.store(in: &cancellables)
		
		repository.updatedInvitedUser
			.subscribe(invitationResult)
			.store(in: &cancellables)
		
		repository.invitationReceived
			.subscribe(invitationReceived)
			.store(in: &cancellables)
	}
}
