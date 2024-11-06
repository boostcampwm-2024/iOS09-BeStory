//
//  GroupInfoTest.swift
//  GroupInfoTest
//
//  Created by Yune gim on 11/7/24.
//

import Combine
import DomainInterface
import XCTest

final class GroupInfoTest: XCTestCase {
    func test_emitUser_whenUserInvited() throws {
        let dummySubject = PassthroughSubject<GroupInfoViewInput, Never>().eraseToAnyPublisher()
        let groupTitle = "iOS09 - 차은우원빈현빈장원영"
        let users = [
            "건우",
            "지혜",
            "석영"
        ].map { DomainInterface.InvitedUser(id: $0, name: $0, state: .connected) }
        
        let mockUsecase = MockUseCase(title: groupTitle)
        let sut = GroupInfoViewModel(usecase: mockUsecase)
        
        var inviteResult = [DomainInterface.InvitedUser]()
        
        let cancellable = sut.transform(input: dummySubject).sink { result in
            switch result {
            case .userDidInvited(user: let user):
                inviteResult.append(user)
            default: break
            }
        }
        
        users.forEach {
            mockUsecase.invitedUser.send($0)
        }
        
        XCTAssertEqual(users, inviteResult)
        cancellable.cancel()
    }
    
    func test_emitUser_whenUserStateUpdated() throws {
        let dummySubject = PassthroughSubject<GroupInfoViewInput, Never>().eraseToAnyPublisher()
        let groupTitle = "iOS09 - 차은우원빈현빈장원영"
        let user = DomainInterface.InvitedUser(id: "건우", name: "건우", state: .connected)
        
        let mockUsecase = MockUseCase(title: groupTitle)
        let sut = GroupInfoViewModel(usecase: mockUsecase)
        
        var updateResult: DomainInterface.InvitedUser?
        
        let cancellable = sut.transform(input: dummySubject).sink { result in
            switch result {
            case .userStateDidChanged(user: let user):
                updateResult = user
            default: break
            }
        }
        
        mockUsecase.updatedUser.send(user)
        
        XCTAssertEqual(user, updateResult)
        cancellable.cancel()
    }
}

class MockUseCase: UpdateGroupInfoUseCaseInterface {
    var invitedUser = PassthroughSubject<DomainInterface.InvitedUser, Never>()
    
    var updatedUser = PassthroughSubject<DomainInterface.InvitedUser, Never>()
    
    var updatedTitle: CurrentValueSubject<String, Never>
    
    init(title: String) {
        updatedTitle = CurrentValueSubject<String, Never>(title)
    }
}
