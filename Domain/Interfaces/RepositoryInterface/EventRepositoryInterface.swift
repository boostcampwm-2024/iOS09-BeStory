//
//  NoticedEventRepositoryInterface.swift
//  Interfaces
//
//  Created by Yune gim on 12/2/24.
//

import Combine
import Entity

public protocol NoticedEventRepositoryInterface {
    var receivedEvent: PassthroughSubject<Event, Never> { get }
    
    func notice(event: Event)
}
