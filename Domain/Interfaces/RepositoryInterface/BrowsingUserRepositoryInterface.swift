//
//  BrowsingUserRepositoryInterface.swift
//  DataInterface
//
//  Created by jung on 11/7/24.
//

import Combine
import Entity

public protocol BrowsingUserRepositoryInterface {
	var updatedBrowsingUser: PassthroughSubject<BrowsedUser, Never> { get }
	var updatedInvitedUser: PassthroughSubject<InvitedUser, Never> { get }
	var invitationReceived: PassthroughSubject<BrowsedUser, Never> { get }
    var receivedEvent: PassthroughSubject<OpeningEvent, Never> { get }
    var isInGroup: CurrentValueSubject<Bool, Never> { get }

	func fetchBrowsingUsers() -> [BrowsedUser]
	func inviteUser(with id: String, timeout: Double)
	func acceptInvitation()
	func rejectInvitation()
	func startReceiveInvitation()
	func stopReceiveInvitation()
    func notice(event: OpeningEvent)
    func stopAdvertising()
    func startAdvertising()
}
