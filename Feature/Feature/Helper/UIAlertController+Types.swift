//
//  UIAlertController+Types.swift
//  Feature
//
//  Created by 이숲 on 11/22/24.
//

import UIKit

extension UIAlertController {
    enum AlertType {
        case requestInvitation
        case invitationReceivedBy(name: String)
        case invitationAcceptedBy(name: String)
        case invitationRejectedBy(name: String)
        case invitationTimeout
        case invitationLostFrom(name: String)
        case custom(title: String, message: String)
    }

    enum ActionType {
        case confirm(handler: (() -> Void)? = nil)
        case cancel(handler: (() -> Void)? = nil)
        case custom(
            title: String,
            style: UIAlertAction.Style,
            handler: (() -> Void)? = nil
        )
        case none
    }

    convenience init(type: AlertType, actions: [( ActionType )] = []) {
        switch type {
        case .requestInvitation:
            self.init(
                title: "Request Invitation",
                message: "상대방을 초대하시겠습니까?",
                preferredStyle: .alert
            )
        case .invitationReceivedBy(let name):
            self.init(
                title: "Invitation Received",
                message: "\(name)의 초대를 수락하시겠습니까?",
                preferredStyle: .alert
            )
        case .invitationAcceptedBy(let name):
            self.init(
                title: "Invitation Accepted",
                message: "\(name)이 초대를 수락했습니다.",
                preferredStyle: .alert
            )
        case .invitationRejectedBy(let name):
            self.init(
                title: "Invitation Rejected",
                message: "\(name)이 초대를 거절했습니다.",
                preferredStyle: .alert
            )
        case .invitationTimeout:
            self.init(
                title: "Invitation Timeout",
                message: "응답시간이 초과되었습니다.",
                preferredStyle: .alert
            )
        case .invitationLostFrom(let name):
            self.init(
                title: "Invitation Lost",
                message: "\(name)의 연결이 끊겼습니다.",
                preferredStyle: .alert
            )
        case .custom(let title, let message):
            self.init(
                title: title,
                message: message,
                preferredStyle: .alert
            )
        }

        addActions(actions: actions)
    }

    private func addActions(
        actions: [( ActionType )] = []
    ) {
        actions.forEach { actionType in
            var action = UIAlertAction()

            switch actionType {
            case .confirm(let handler):
                action = UIAlertAction(title: "확인", style: .default) { _ in
                    handler?()
                }
            case .cancel(let handler):
                action = UIAlertAction(title: "취소", style: .cancel) { _ in
                    handler?()
                }
            case .custom(let title, let style, let handler):
                action = UIAlertAction(title: title, style: style) { _ in
                    handler?()
                }
            case .none:
                break
            }

            self.addAction(action)
        }
    }
}
