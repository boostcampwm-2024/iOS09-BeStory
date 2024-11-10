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
	let browsedUser = PassthroughSubject<BrowsedUser, Never>()
	
	init(repository: BrowsingUserRepositoryInterface) {
		self.repository = repository
		
		repository.updatedBrowsingUser
			.subscribe(browsedUser)
			.store(in: &cancellables)
	}
	
	func fetchBrowsedUsers() -> [BrowsedUser] {
		return repository.fetchBrowsingUsers()
	}
	
	func inviteUser(with id: String) { }
}
