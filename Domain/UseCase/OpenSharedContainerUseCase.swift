//
//  OpenSharedContainerUseCase.swift
//  UseCase
//
//  Created by Yune gim on 12/2/24.
//

import Combine
import Entity
import Interfaces

public final class OpenSharedContainerUseCase: OpenSharedContainerUseCaseInterface {
    private let repository: NoticedEventRepositoryInterface
    private var cancellables: Set<AnyCancellable> = []

    public var openEvent = PassthroughSubject<Void, Never>()

    public init(repository: NoticedEventRepositoryInterface) {
        self.repository = repository
        bind()
    }
}

// MARK: - Public Methods
public extension OpenSharedContainerUseCase {
    func noticeOpening() {
        repository.notice(event: Event.openSharedContainer)
        openEvent.send()
    }
}

// MARK: - Private Methods
private extension OpenSharedContainerUseCase {
    func bind() {
        repository.receivedEvent
            .sink { [weak self] event in
                if event == .openSharedContainer {
                    self?.openEvent.send()
                }
            }
            .store(in: &cancellables)
    }
}
