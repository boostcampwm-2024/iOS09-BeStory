//
//  MockBrowinsgUseCase.swift
//  UseCaseTest
//
//  Created by jung on 11/7/24.
//

@testable import Interfaces
import Combine
import Entity

final class MockBrowinsgUseCase: BrowsingUserUseCaseInterface {
	private var cancellables: Set<AnyCancellable> = []
	private let repository: BrowsingUserRepositoryInterface
	let browsingUser = PassthroughSubject<BrowsingUser, Never>()
	
	init(repository: BrowsingUserRepositoryInterface) {
		self.repository = repository
		
		repository.updatedBrowsingUser
			.subscribe(browsingUser)
			.store(in: &cancellables)
	}
	
	func fetchBrowsingUsers() -> [BrowsingUser] {
		return repository.fetchBrowsingUsers()
	}
	
	func inviteUser(with id: String) { }
}
