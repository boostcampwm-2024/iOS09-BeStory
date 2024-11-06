//
//  UpdateGroupInfoUseCase.swift
//  Domain
//
//  Created by jung on 11/4/24.
//

import Combine
import DomainInterface

public class UpdateGroupInfoUseCase: UpdateGroupInfoUseCaseInterface {
    public let invitedUser = PassthroughSubject<DomainInterface.InvitedUser, Never>()
    public let updatedUser = PassthroughSubject<DomainInterface.InvitedUser, Never>()
    public let updatedTitle: CurrentValueSubject<String, Never>
    
    public init(title: String) {
        self.updatedTitle = CurrentValueSubject<String, Never>(title)
    }
}
