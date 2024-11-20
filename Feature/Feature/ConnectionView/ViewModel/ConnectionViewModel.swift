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

final public class ConnectionViewModel {
    // MARK: - Typealias

    typealias Input = ConnectionViewInput
    typealias Output = ConnectionViewOutput

    // MARK: - Properties

    private let usecase: BrowsingUserUseCaseInterface
    private var output = PassthroughSubject<Output, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private var centerPosition: (Double, Double)?
    private var innerDiameter: Float?
    private var outerDiameter: Float?
    private var usedPositions: [String: (Double, Double)] = [:]

    private let emojis = ["😀", "😊", "🤪", "🤓", "😡", "🥶", "🤯", "🤖", "👻", "👾"]

    // MARK: - Initializer

    public init(usecase: BrowsingUserUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }

    func configure(
        centerPosition: (Double, Double),
        innerDiameter: Float,
        outerDiameter: Float
    ) {
        self.centerPosition = centerPosition
        self.innerDiameter = innerDiameter
        self.outerDiameter = outerDiameter
    }
}

// MARK: - Transform

extension ConnectionViewModel {
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] result in
            guard let self else { return }

            switch result {
            // Connection Input

            case .fetchUsers:
                fetchUsers().forEach({ self.found(user: $0) })
            case .invite(let id):
                invite(id: id)

            // Invitation Input

            case .accept(let id):
                acceptInvitation(from: id)
            case .reject(let id):
                rejectInvitation(from: id)
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}

// MARK: - UseCase Methods

private extension ConnectionViewModel {
    // Connection Methods

    func fetchUsers() -> [BrowsedUser] {
        return usecase.fetchBrowsedUsers()
    }

    func invite(id: String) {
        usecase.inviteUser(with: id)
    }

    // Invitation Methods

    func acceptInvitation(from id: String) {
        usecase.acceptInvitation(from: id)
    }

    func rejectInvitation(from id: String) {
        usecase.rejectInvitation(from: id)
    }
}

// MARK: - Binding

private extension ConnectionViewModel {
    func setupBind() {
        // Broswed User (found, lost)

        usecase.browsedUser
            .sink { [weak self] updatedUser in
                guard let self else { return }

                switch updatedUser.state {
                case .found:
                    found(user: updatedUser)
                case .lost:
                    lost(user: updatedUser)
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // Invitation Received (From Who)

        usecase.invitationReceived
            .sink { [weak self] invitingUser in
                guard let self else { return }

                output.send(.invited(from: invitingUser))
            }
            .store(in: &cancellables)

        // Invitation Result (when I invite other users)

        usecase.invitationResult
            .sink { [weak self] invitedUser in
                guard let self else { return }

                switch invitedUser.state {
                case .accept:
                    output.send(.accepted(name: invitedUser.name))
                case .reject:
                    output.send(.rejected(name: invitedUser.name))
                }
            }
            .store(in: &cancellables)

        // Invitaion Fired Due to Timeout (invited user receive)

        usecase.invitationDidFired
            .sink { [weak self] in
                guard let self else { return }

                output.send(.timeout)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Output Methods

private extension ConnectionViewModel {
    func found(user: BrowsedUser) {
        guard
            self.getCurrentPosition(id: user.id) == nil,
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

    func lost(user: BrowsedUser) {
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

    func getRandomPosition() -> (Double, Double)? {
        guard
            let centerPosition = self.centerPosition,
            let innerDiameter = self.innerDiameter,
            let outerDiameter = self.outerDiameter
        else { return nil }

        let maxAttempts = usedPositions.count + 1
        var attempts = 0
        var position: (Double, Double)

        repeat {
            attempts += 1

            let innerRadius = innerDiameter / 2
            let outerRadius = outerDiameter / 2

            let randomRadius = Float.random(in: innerRadius...outerRadius)
            let angle = Float.random(in: 0...(2 * .pi))

            position = (
                (centerPosition.0 + Double(randomRadius * cos(angle))).rounded(),
                (centerPosition.1 + Double(randomRadius * sin(angle))).rounded()
            )
        } while usedPositions.contains(where: {
            $0.value.0.distance(to: position.0) < 50 ||
            $0.value.1.distance(to: position.1) < 50
        }) && attempts < maxAttempts

        return position
    }

    func getCurrentPosition(id: String) -> (Double, Double)? {
        return usedPositions[id]
    }

    func addCurrentPosition(id: String, position: (Double, Double)) {
        usedPositions[id] = position
    }

    func removeCurrentPosition(id: String) {
        usedPositions.removeValue(forKey: id)
    }
}
