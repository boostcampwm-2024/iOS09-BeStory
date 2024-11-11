//
//  ConnectionViewModel.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import Combine
import Foundation
import UIKit

protocol ConnectionViewModelable: ViewModelable where
Input == ConnectionInput,
Output == ConnectionOutput { }

final public class ConnectionViewModel {
    // MARK: - Properties
    private let usecase: BrowsingUserUseCaseInterface
    private var cancellables: Set<AnyCancellable> = []

    var output = PassthroughSubject<Output, Never>()

    private let emojis = ["😀", "😇", "😎", "🤓", "😡", "🥶", "🤯", "🤖", "👻", "👾"]
    private var usedPositions: [String: CGPoint] = [:]

    // MARK: - Initializer

    init(usecase: BrowsingUserUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }
}

// MARK: - Transform

extension ConnectionViewModel: ConnectionViewModelable {
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] result in
            switch result {
            case .fetchUsers:
                guard let users = self?.fetchUsers() else { return }
                self?.output.send(.fetched(users))
            case .invite(let id):
                self?.invite(id: id)
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - Binding

private extension ConnectionViewModel {
    func setupBind() {
        usecase.browsingUser
            .sink { [weak self] updatedUser in
                self?.output.send(.updated(updatedUser))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private Methods

private extension ConnectionViewModel {
    func fetchUsers() -> [BrowsingUser] {
        return usecase.fetchBrowsingUsers()
    }

    func invite(id: String) {
        usecase.inviteUser(with: id)
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
        } while usedPositions.contains(where: {
            $0.value.distance(to: position) < 50
        }) && attempts < maxAttempts

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
