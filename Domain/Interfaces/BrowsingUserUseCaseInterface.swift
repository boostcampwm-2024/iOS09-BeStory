//
//  BrowsingUserUseCaseInterface.swift
//  DomainInterface
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity

public protocol BrowsingUserUseCaseInterface {
	/// browsing된 유저의 상태(`found`, `lost`)가 해당 stream을 통해 방출됩니다.
	var browsedUser: PassthroughSubject<BrowsedUser, Never> { get }
	/// 초대한 유저의 수락 및 거절 정보가 해당 stream을 통해 방출됩니다.
	var invitationResult: PassthroughSubject<InvitedUser, Never> { get }
	/// 초대를 받은 경우, 해당 stream을 통해 이벤트가 방출됩니다.
	var invitationReceived: PassthroughSubject<BrowsedUser, Never> { get }
	/// 초대를 받은 유저가, 초대 시간이 만료되었을 때 stream을 통해 이벤트가 방출됩니다.
	var invitationDidFired: PassthroughSubject<Void, Never> { get }
	
	init(repository: BrowsingUserRepositoryInterface, invitationTimeout: Double)
	
	func fetchBrowsedUsers() -> [BrowsedUser]
	func inviteUser(with id: String)
	func acceptInvitation(from id: String)
	func rejectInvitation(from id: String)
}
