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
    /// 다른 유저로부터, 연결될 경우, 해당 이벤트로 방출됩니다. (ex 초대를 받고 연결이 맺어졌을 때, 다른 유저가 초대한 유저와 연결이 이루어졌을 때 방출됩니다.
    var connectedUser: PassthroughSubject<InvitedUser, Never> { get }
	/// 초대를 받은 유저가, 초대 시간이 만료되었을 때 stream을 통해 이벤트가 방출됩니다. 초대받은 유저만 이벤트를 받습니다. 초대한 유저의 경우 timeout은 reject이벤트로 옵니다.
	var invitationDidFired: PassthroughSubject<Void, Never> { get }
    /// 공유 컨테이너로 화면 전환을 알리는 이벤트를 방출합니다.
    var openingEvent: PassthroughSubject<Void, Never> { get }
    /// 유저가 그룹 상태인지 확인합니다.
    var isInGroup: CurrentValueSubject<Bool, Never> { get }
	
	func fetchBrowsedUsers() -> [BrowsedUser]
	func inviteUser(with id: String)
	func acceptInvitation()
	func rejectInvitation()
    func noticeOpening()
    func startAdvertising()
    func stopAdvertising()
}
