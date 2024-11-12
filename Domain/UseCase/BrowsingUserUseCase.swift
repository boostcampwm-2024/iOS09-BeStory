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
	private let repository: BrowsingUserRepositoryInterface
	
	public let browsedUser = PassthroughSubject<BrowsedUser, Never>()

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
		return repository.inviteUser(with: id)
	}
}

// MARK: - Private Methods
private extension BrowsingUserUseCase {
	func bind() {
		repository.updatedBrowsingUser
			.subscribe(browsedUser)
			.store(in: &cancellables)
	}
}
