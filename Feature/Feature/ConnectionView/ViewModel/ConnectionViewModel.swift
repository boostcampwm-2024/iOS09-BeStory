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

    private var centerPosition: CGPoint?
    private var innerRadius: CGFloat?
    private var outerRadius: CGFloat?
    private var usedPositions: [String: CGPoint] = [:]

    // MARK: - Initializer

    public init(usecase: BrowsingUserUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }

    func configure(
        centerPosition: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat
    ) {
        self.centerPosition = centerPosition
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
    }

    func compareCenter(currentCenter: CGPoint) -> Bool {
        guard self.centerPosition == currentCenter else { return false }
        return true
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
                usecase.fetchBrowsedUsers().forEach({ self.found(user: $0) })
            case .inviteUser(let id):
                usecase.inviteUser(with: id)

            // Invitation Input

            case .acceptInvitation(let user):
                usecase.acceptInvitation()
                removeCurrentPosition(id: user.id)
            case .rejectInvitation:
                usecase.rejectInvitation()
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
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
                }
            }
            .store(in: &cancellables)

        // Invitation Received (From Who)

        usecase.invitationReceived
            .sink { [weak self] invitingUser in
                guard let self else { return }
                output.send(.invitedGroupBy(user: invitingUser))
            }
            .store(in: &cancellables)

        // Invitation Result (when I invite other users)

        usecase.invitationResult
            .sink { [weak self] invitedUser in
                guard let self else { return }

                switch invitedUser.state {
                case .accept:
                    self.removeCurrentPosition(id: invitedUser.id)
                    output.send(.invitationAcceptedBy(user: BrowsedUser(
                        id: invitedUser.id,
                        state: .found,
                        name: invitedUser.name
                    )))
                case .reject:
                    output.send(.invitationRejectedBy(name: invitedUser.name))
                }
            }
            .store(in: &cancellables)

        // Invitaion Fired Due to Timeout (invited user receive)

        usecase.invitationDidFired
            .sink { [weak self] in
                guard let self else { return }

                output.send(.invitationTimeout)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Output Methods

private extension ConnectionViewModel {
    func found(user: BrowsedUser) {
        guard
            self.getCurrentPosition(id: user.id) == nil,
            let emoji = EmojiManager.shared.getRandomEmoji(id: user.id)
        else { return }

        let position = self.getRandomPosition()
        self.addCurrentPosition(id: user.id, position: position)

        self.output.send(
            .foundUser(
                user: user,
                position: position,
                emoji: emoji
            )
        )
    }

    func lost(user: BrowsedUser) {
        self.removeCurrentPosition(id: user.id)
        EmojiManager.shared.removeUserEmoji(id: user.id)
        self.output.send(.lostUser(user: user))
    }
}

// MARK: - Internal Methods

extension ConnectionViewModel {
    func getRandomPosition() -> CGPoint {
        guard
            let centerPosition = self.centerPosition,
            let innerRadius = self.innerRadius,
            let outerRadius = self.outerRadius
        else { return CGPoint.zero }

        let maxAttempts = usedPositions.count + 1
        var attempts = 0
        var position: CGPoint

        repeat {
            attempts += 1

            let randomRadius = CGFloat.random(in: innerRadius...outerRadius)
            let angle = CGFloat.random(in: 0...(2 * .pi))

            position = CGPoint(
                x: centerPosition.x + randomRadius * cos(angle),
                y: centerPosition.y + randomRadius * sin(angle)
            )
        } while usedPositions.contains(where: {
            $0.value.x.distance(to: position.x) < 50 || $0.value.y.distance(to: position.y) < 50
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
