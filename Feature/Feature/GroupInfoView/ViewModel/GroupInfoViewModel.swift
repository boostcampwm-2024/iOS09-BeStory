//
//  GroupInfoViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine

public class GroupInfoViewModel {
    typealias Input = GroupInfoViewInput
    typealias Output = GroupInfoViewOutput
    
    private var users = [InvitedUser]()
    private var title: String = ""
    
    var output = PassthroughSubject<GroupInfoViewOutput, Never>()
    var cancellables: Set<AnyCancellable> = []

    public init() { }

    func transform(input: AnyPublisher<GroupInfoViewInput, Never>) -> AnyPublisher<GroupInfoViewOutput, Never> {
        input.sink { [weak self] inputResult in
            switch inputResult {
            case .viewDidLoad:
                self?.output.send(.titleDidChanged(title: self?.title ?? ""))
            case .exitGroupButtonDidTab:
                self?.exitGroupButtonDidTab()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension GroupInfoViewModel {
    func userStateDidChanged(user: InvitedUser) {
        for index in users.indices {
            guard users[index].id == user.id else { continue }
            users[index] = user
        }
        output.send(.userStateDidChanged(user: user))
    }
    
    func userDidInvited(user: InvitedUser) {
        users.append(user)
        output.send(.userDidInvited(user: user))
        output.send(.groupCountDidChanged(count: users.count))
    }
    
    func exitGroupButtonDidTab() { }
}

enum GroupInfoViewInput {
    case viewDidLoad
    case exitGroupButtonDidTab
}

enum GroupInfoViewOutput {
    case userStateDidChanged(user: InvitedUser)
    case userDidInvited(user: InvitedUser)
    case groupCountDidChanged(count: Int)
    case titleDidChanged(title: String)
}
