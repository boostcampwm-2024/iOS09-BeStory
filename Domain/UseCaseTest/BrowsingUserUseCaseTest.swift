//
//  BrowsingUserUseCaseTest.swift
//  UseCaseTest
//
//  Created by jung on 11/7/24.
//

@testable import UseCase

import XCTest
import Data
import Entity
import Interfaces
import P2PSocket

final class BrowsingUserUseCaseTest: XCTestCase {
	private var sut: BrowsingUserUseCaseInterface!
	private var secondarySut: BrowsingUserUseCaseInterface!
	private var mockSocketProvider: MockSocketProvider!
	private var secondaryMockSocketProvider: MockSocketProvider!
	
	override func setUp() {
		super.setUp()
		self.mockSocketProvider = MockSocketProvider()
		self.secondaryMockSocketProvider = MockSocketProvider()
		let repository = BrowsingUserRepository(socketProvider: mockSocketProvider)
		let secondaryRepository = BrowsingUserRepository(socketProvider: secondaryMockSocketProvider)
		
		sut = BrowsingUserUseCase(repository: repository, invitationTimeout: 1.0)
		secondarySut = BrowsingUserUseCase(repository: secondaryRepository, invitationTimeout: 1.0)
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
}

// MARK: - Browsing Test
extension BrowsingUserUseCaseTest {
	func test_이미_있는_유저가_잘_감지되는지() {
		// given
		let mockBrowsedUsers: [SocketPeer] = [
			.init(id: "0", name: "석영", state: .found),
			.init(id: "1", name: "윤회", state: .found),
			.init(id: "2", name: "건우", state: .found),
			.init(id: "3", name: "지혜", state: .found)
		]
		
		// when
		mockSocketProvider.mockPeers = mockBrowsedUsers
		let browsedUsers = sut.fetchBrowsedUsers()
		
		// then
		XCTAssertEqual(browsedUsers.count, 4)
	}
	
	func test_새로운_유저가_잘_감지되는지() {
		// given
		let mockBrowsingUser = SocketPeer(id: "4", name: "JK", state: .found)
		let publisher = sut.browsedUser
		var receivedPeer: BrowsedUser?
		let cancellable = publisher.sink { peer in 
			receivedPeer = peer
		}
		
		// when
		mockSocketProvider.updatedPeer.send(mockBrowsingUser)
		
		// then
		XCTAssertEqual(receivedPeer?.id, mockBrowsingUser.id)
		cancellable.cancel()
	}
	
	func test_유저의_lost가_잘_감지되는지() {
		// given
		let mockBrowsingUser = SocketPeer(id: "4", name: "JK", state: .lost)
		let publisher = sut.browsedUser
		var receivedPeer: BrowsedUser?
		let cancellable = publisher.sink { peer in
			receivedPeer = peer
		}
		
		// when
		mockSocketProvider.updatedPeer.send(mockBrowsingUser)
		
		// then
		XCTAssertEqual(receivedPeer?.state, .lost)
		cancellable.cancel()
	}
}

// MARK: - Invitation Test
extension BrowsingUserUseCaseTest {
	func test_초대시_timeout될시_reject이벤트가_잘오는지() {
		// given
		let expectation = XCTestExpectation(description: "timeout테스트")
		mockSocketProvider.invitationResultState = .timeout
		let publisher = sut.invitationResult
		var invitationUser: InvitedUser?
		let cancellable = publisher.sink { peer in
			invitationUser = peer
			expectation.fulfill()
		}
		// when
		sut.inviteUser(with: "1")
		
		// then
		wait(for: [expectation], timeout: .init(1))
		XCTAssertEqual(invitationUser?.state, .reject)
		cancellable.cancel()
	}
}
