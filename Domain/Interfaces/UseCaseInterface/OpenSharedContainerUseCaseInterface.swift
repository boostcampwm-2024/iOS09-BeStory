//
//  OpenSharedContainerUseCaseInterface.swift
//  Interfaces
//
//  Created by Yune gim on 12/2/24.
//

import Combine

public protocol OpenSharedContainerUseCaseInterface {
    var openEvent: PassthroughSubject<Void, Never> { get }
    
    func noticeOpening()
}
