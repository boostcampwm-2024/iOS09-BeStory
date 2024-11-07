//
//  BrowsingUserUseCase.swift
//  Domain
//
//  Created by jung on 11/7/24.
//

import Combine
import DomainInterface
import Entity
import DataInterface

public final class BrowsingUserUseCase: BrowsingUserUseCaseInterface {
	private var cancellables: Set<AnyCancellable> = []
	private let repository: BrowsingUserRepositoryInterface
	
	public let browsingUser = PassthroughSubject<BrowsingUser, Never>()

	public init(repository: BrowsingUserRepositoryInterface) {
		self.repository = repository
		bind()
	}
}

// MARK: - Public Methods
public extension BrowsingUserUseCase {
	func fetchBrowsingUsers() -> [BrowsingUser] {
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
			.subscribe(browsingUser)
			.store(in: &cancellables)
	}
}
