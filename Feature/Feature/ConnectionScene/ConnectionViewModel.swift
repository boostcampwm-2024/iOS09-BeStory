//
//  ConnectionViewModel.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import Foundation
import UIKit
import Combine

final public class ConnectionViewModel {
    // MARK: - Properties
    private let usecase: BrowsingUserUseCaseInterface
    private var cancellables: Set<AnyCancellable> = []

    private let emojis = ["😀", "😇", "😎", "🤓", "😡", "🥶", "🤯", "🤖", "👻", "👾"]
    private var usedPositions: [String: CGPoint] = [:]

    @Published private(set) var users: [BrowsingUser] = []

    // MARK: - Initializer

    init(usecase: BrowsingUserUseCaseInterface) {
        self.usecase = usecase
        bind()
    }

    func fetchUsers() {
        if users.isEmpty {
            users = usecase.fetchBrowsingUsers()
        }
    }

    func invite(id: String) {
        usecase.inviteUser(with: id)
    }
}

// MARK: - Binding

private extension ConnectionViewModel {
    func bind() {
        usecase.browsingUser
            .sink { [weak self] updatedUser in
                guard let self = self else { return }

                if !users.contains(where: { $0.id == updatedUser.id }) {
                    users.append(updatedUser)
                } else {
                    for (index, user) in users.enumerated() where user.id == updatedUser.id {
                        users[index] = updatedUser
                        break
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Internal Methods

extension ConnectionViewModel {
    func getRandomEmoji() -> String {
        return emojis.randomElement() ?? "🙂"
    }

    func getRandomPosition(
        innerDiameter: CGFloat,
        outerDiameter: CGFloat,
        center: CGPoint,
        maxAttempts: Int
    ) -> CGPoint {
        var position: CGPoint
        var attempts = 0

        repeat {
            attempts += 1

            let innerRadius = innerDiameter / 2
            let outerRadius = outerDiameter / 2

            let randomRadius = CGFloat.random(in: innerRadius...outerRadius)
            let angle = CGFloat.random(in: 0...(2 * .pi))

            position = CGPoint(
                x: center.x + randomRadius * cos(angle),
                y: center.y + randomRadius * sin(angle)
            )
        } while usedPositions.contains(where: { $0.value.distance(to: position) < 50 }) && attempts < maxAttempts

        return position
    }

    func addCurrentPosition(id: String, position: CGPoint) {
        usedPositions[id] = position
    }

    func getCurrentPosition(id: String) -> CGPoint? {
        return usedPositions[id]
    }

    func removeCurrentPosition(id: String) {
        usedPositions.removeValue(forKey: id)
    }
}

// MARK: - Test 용

struct BrowsingUser: Identifiable {
    enum State {
        case lost
        case found
    }

    let id: String
    let state: State
    let name: String
}

protocol BrowsingUserUseCaseInterface {
    var browsingUser: PassthroughSubject<BrowsingUser, Never> { get }

    init()

    func fetchBrowsingUsers() -> [BrowsingUser]
    func inviteUser(with id: String)
}
