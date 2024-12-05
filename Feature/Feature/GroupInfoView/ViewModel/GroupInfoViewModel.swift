//
//  GroupInfoViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import Entity
import Interfaces

protocol GroupInfoCoordinatable: AnyObject {
    func exitGroupButtonDidTap()
}

public final class GroupInfoViewModel {
    typealias Input = GroupInfoViewInput
    typealias Output = GroupInfoViewOutput
    
    private var users = [ConnectedUser]()
    private let usecase: ConnectedUserUseCaseInterface
    
    var output = PassthroughSubject<GroupInfoViewOutput, Never>()
    var cancellables: Set<AnyCancellable> = []

    weak var coordinator: GroupInfoCoordinatable?

    public init(usecase: ConnectedUserUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }

    func transform(input: AnyPublisher<GroupInfoViewInput, Never>) -> AnyPublisher<GroupInfoViewOutput, Never> {
        input.sink { [weak self] inputResult in
            guard let self else { return }
            
            switch inputResult {
            case .viewDidLoad:
                usecase.fetchConnectedUsers().forEach { user in
                    self.output.send(.userDidInvited(user: user))
                }
            case .exitGroupButtonDidTab:
                exitGroupButtonDidTab()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension GroupInfoViewModel {
    func setupBind() {
        usecase.updatedConnectedUser
            .sink { [weak self] updatedUser in
                guard let self else { return }
                switch updatedUser.state {
                case .connected:
                    userDidInvited(user: updatedUser)
                case .disconnected:
                    userDidExit(user: updatedUser)
                }
            }
            .store(in: &cancellables)
    }
    
    func userStateDidChanged(user: ConnectedUser) {
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            guard users[userIndex].state != user.state else { return }
            users[userIndex] = user
        }
        output.send(.userStateDidChanged(user: user))
    }
    
    func userDidInvited(user: ConnectedUser) {
        if users.contains(where: { $0.id == user.id }) {
            return userStateDidChanged(user: user)
        }
        users.append(user)
        output.send(.userDidInvited(user: user))
        output.send(.groupCountDidChanged(count: users.count))
    }
    
    func userDidExit(user: ConnectedUser) {
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: userIndex)
        }
        output.send(.userDidExit(user: user))
        output.send(.groupCountDidChanged(count: users.count))
    }
    
    func exitGroupButtonDidTab() {
        usecase.leaveGroup()
        coordinator?.exitGroupButtonDidTap()
    }
}
