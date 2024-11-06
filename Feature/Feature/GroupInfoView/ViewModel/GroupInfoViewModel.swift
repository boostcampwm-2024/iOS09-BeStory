//
//  GroupInfoViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine

class GroupInfoViewModel: ViewModelProtocol {
    typealias Input = GroupInfoViewInput
    typealias Output = GroupInfoViewOutput
    
    var output = PassthroughSubject<GroupInfoViewOutput, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    func transform(input: AnyPublisher<GroupInfoViewInput, Never>) -> AnyPublisher<GroupInfoViewOutput, Never> {
        input.sink { [weak self] inputResult in
            switch inputResult {
            case .viewDidLoad:
                self?.userStateDidChanged()
            case .exitGroupButtonDidTab:
                self?.exitGroupButtonDidTab()
            }
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

private extension GroupInfoViewModel {
    func userStateDidChanged() {
        output.send(.userStateDidChanged(user: .init(id: "건우",
                                                     name: "건우",
                                                     state: .notConnected)))
    }
    
    func exitGroupButtonDidTab() { }
}

enum GroupInfoViewInput {
    case viewDidLoad
    case exitGroupButtonDidTab
}

enum GroupInfoViewOutput {
    case userStateDidChanged(user: InvitedUser)
}

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    var output: PassthroughSubject<Output, Never> { get set }
    var cancellables: Set<AnyCancellable> { get set }
 
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
