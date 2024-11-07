//
//  BrowsingUserUseCaseTest.swift
//  UseCaseTest
//
//  Created by jung on 11/7/24.
//

import XCTest
@testable import Interfaces
import Entity
import P2PSocket

final class BrowsingUserUseCaseTest: XCTestCase {
	private var sut: MockBrowinsgUseCase!
	private var mockSocketProvider: MockSocketProvider!
	private var mockRepository: MockBrowsingUserRepository!
	
	override func setUp() {
		super.setUp()
		self.mockSocketProvider = MockSocketProvider()
		self.mockRepository = MockBrowsingUserRepository(socketProvider: mockSocketProvider)
		sut = MockBrowinsgUseCase(repository: mockRepository)
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
}

// MARK: - Test
extension BrowsingUserUseCaseTest {
	func test_이미_있는_유저가_잘_감지되는지() {
		// given
		let mockBrowsingUsers: [SocketPeer] = [
			.init(id: "0", name: "석영", state: .found),
			.init(id: "1", name: "윤회", state: .found),
			.init(id: "2", name: "건우", state: .found),
			.init(id: "3", name: "지혜", state: .found)
		]
		
		// when
		mockSocketProvider.mockPeers = mockBrowsingUsers
		let browsingUsers = mockSocketProvider.browsingPeers()
		
		// then
		XCTAssertEqual(browsingUsers.count, 4)
	}
	
	func test_새로운_유저가_잘_감지되는지() {
		// given
		let expectation = XCTestExpectation(description: "새로운 유저 테스트")
		let mockBrowsingUser = SocketPeer(id: "4", name: "JK", state: .found)
		let publisher = sut.browsingUser
		var receivedPeer: BrowsingUser?
		let cancellable = publisher.sink { peer in
			receivedPeer = peer
			expectation.fulfill()
		}
		
		// when
		mockSocketProvider.updatedPeer.send(mockBrowsingUser)
		
		// then
		wait(for: [expectation], timeout: 0.2)
		XCTAssertEqual(receivedPeer?.id, mockBrowsingUser.id)
		cancellable.cancel()
	}
	
	func test_유저의_lost가_잘_감지되는지() {
		// given
		let expectation = XCTestExpectation(description: "새로운 유저 테스트")
		let mockBrowsingUser = SocketPeer(id: "4", name: "JK", state: .lost)
		let publisher = sut.browsingUser
		var receivedPeer: BrowsingUser?
		let cancellable = publisher.sink { peer in
			receivedPeer = peer
			expectation.fulfill()
		}
		
		// when
		mockSocketProvider.updatedPeer.send(mockBrowsingUser)
		
		// then
		wait(for: [expectation], timeout: 0.2)
		XCTAssertEqual(receivedPeer?.state, .lost)
		cancellable.cancel()
	}
}
