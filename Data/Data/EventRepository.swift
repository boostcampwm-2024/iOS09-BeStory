//
//  NoticedEventRepository.swift
//  Data
//
//  Created by Yune gim on 12/2/24.
//

import Combine
import Entity
import Foundation
import Interfaces
import P2PSocket

public final class NoticedEventRepository: NoticedEventRepositoryInterface {
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: SocketProvidable

    public var receivedEvent = PassthroughSubject<Event, Never>()

    public init(socketProvider: SocketProvidable) {
        self.socketProvider = socketProvider
        bind()
    }
    
    public func notice(event: Event) {
        guard let eventData = try? JSONEncoder().encode(event) else { return }
        socketProvider.sendAll(data: eventData)
    }
}

private extension NoticedEventRepository {
    func bind() {
        socketProvider.dataShared.sink { [weak self] (data, _) in
            guard let event = try? JSONDecoder().decode(Event.self, from: data) else { return }
            self?.receivedEvent.send(event)
        }
        .store(in: &cancellables)
    }
}
