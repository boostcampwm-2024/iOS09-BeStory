//
//  ConnectionViewModel.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import Combine
import Entity
import Foundation
import Interfaces
import UIKit

protocol ConnectionViewModelable: ViewModelable where
Input == ConnectionInput,
Output == ConnectionOutput { }

final public class ConnectionViewModel {
    // MARK: - Properties
    private let usecase: BrowsingUserUseCaseInterface
    private var output = PassthroughSubject<Output, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private var centerPosition: CGPoint?
    private var innerDiameter: CGFloat?
    private var outerDiameter: CGFloat?
    private var usedPositions: [String: CGPoint] = [:]

    private let emojis = ["😀", "😊", "🤪", "🤓", "😡", "🥶", "🤯", "🤖", "👻", "👾"]

    // MARK: - Initializer

    init(usecase: BrowsingUserUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }

    func configure(
        centerPosition: CGPoint,
        innerDiameter: CGFloat,
        outerDiameter: CGFloat
    ) {
        self.centerPosition = centerPosition
        self.innerDiameter = innerDiameter
        self.outerDiameter = outerDiameter
    }
}

// MARK: - Transform

extension ConnectionViewModel: ConnectionViewModelable {
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] result in
            switch result {
            case .fetchUsers:
                guard let users = self?.fetchUsers() else { return }
                users.forEach({ self?.found($0) })
            case .invite(let id):
                self?.invite(id: id)
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - UseCase Methods

private extension ConnectionViewModel {
    func fetchUsers() -> [BrowsedUser] {
        return usecase.fetchBrowsedUsers()
    }

    func invite(id: String) {
        usecase.inviteUser(with: id)
    }
}

// MARK: - Binding

private extension ConnectionViewModel {
    func setupBind() {
        usecase.browsedUser
            .sink { [weak self] updatedUser in
                switch updatedUser.state {
                case .found:
                    self?.found(updatedUser)
                case .lost:
                    self?.lost(updatedUser)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Output Methods

private extension ConnectionViewModel {
    func found(_ user: BrowsedUser) {
        if self.getCurrentPosition(id: user.id) != nil { return }

        guard
            let position = self.getRandomPosition(),
            let emoji = self.getRandomEmoji()
        else { return }

        self.addCurrentPosition(id: user.id, position: position)

        self.output.send(
            .found(
                user: user,
                position: position,
                emoji: emoji
            )
        )
    }

    func lost(_ user: BrowsedUser) {
        guard let position =  self.getCurrentPosition(id: user.id) else { return }
        self.removeCurrentPosition(id: user.id)
        self.output.send(.lost(user: user, position: position))
    }
}

// MARK: - Internal Methods

extension ConnectionViewModel {
    func getRandomEmoji() -> String? {
        return emojis.randomElement()
    }

    func getRandomPosition() -> CGPoint? {
        guard
            let centerPosition = self.centerPosition,
            let innerDiameter = self.innerDiameter,
            let outerDiameter = self.outerDiameter
        else { return nil }

        let maxAttempts = usedPositions.count + 1
        var attempts = 0
        var position: CGPoint

        repeat {
            attempts += 1

            let innerRadius = innerDiameter / 2
            let outerRadius = outerDiameter / 2

            let randomRadius = CGFloat.random(in: innerRadius...outerRadius)
            let angle = CGFloat.random(in: 0...(2 * .pi))

            position = CGPoint(
                x: centerPosition.x + randomRadius * cos(angle),
                y: centerPosition.y + randomRadius * sin(angle)
            )
        } while usedPositions.contains(where: {
            $0.value.distance(to: position) < 50
        }) && attempts < maxAttempts

        return position
    }

    func getCurrentPosition(id: String) -> CGPoint? {
        return usedPositions[id]
    }

    func addCurrentPosition(id: String, position: CGPoint) {
        usedPositions[id] = position
    }

    func removeCurrentPosition(id: String) {
        usedPositions.removeValue(forKey: id)
    }
}
