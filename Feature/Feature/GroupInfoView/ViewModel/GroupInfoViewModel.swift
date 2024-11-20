//
//  GroupInfoViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import Entity
import Interfaces

public final class GroupInfoViewModel {
    typealias Input = GroupInfoViewInput
    typealias Output = GroupInfoViewOutput
    
    private var users = [ConnectedUser]()
    private var title: String
    private let usecase: ConnectedUserUseCaseInterface
    
    var output = PassthroughSubject<GroupInfoViewOutput, Never>()
    var cancellables: Set<AnyCancellable> = []

    public init(usecase: ConnectedUserUseCaseInterface, title: String) {
        self.usecase = usecase
        self.title = title
        setupBind()
    }
    
    public convenience init(usecase: ConnectedUserUseCaseInterface) {
        let title = "차은우원빈현빈장원영의 이야기"
        self.init(usecase: usecase, title: title)
    }

    func transform(input: AnyPublisher<GroupInfoViewInput, Never>) -> AnyPublisher<GroupInfoViewOutput, Never> {
        input.sink { [weak self] inputResult in
            guard let self else { return }
            
            switch inputResult {
            case .viewDidLoad:
                output.send(.titleDidChanged(title: title))
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
                print(updatedUser)
                switch updatedUser.state {
                case .connected:
                    userDidInvited(user: updatedUser)
                case .disconnected:
                    userDidExit(user: updatedUser)
                case .pending:
                    userStateDidChanged(user: updatedUser)
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
        guard !users.contains(user) else { return }
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
    
    func exitGroupButtonDidTab() { }
}
