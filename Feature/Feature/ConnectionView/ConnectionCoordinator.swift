//
//  ConnectionCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import UIKit

protocol ConnectionListener: AnyObject {
    func nextButtonDidTap(_ coordinator: ConnectionCoordinatable)
}

final class ConnectionCoordinator: Coordinator, ConnectionCoordinatable {
    weak var listener: ConnectionListener?

    private let viewController: ConnectionViewController
    private let viewModel: ConnectionViewModel

    init(viewModel: ConnectionViewModel) {
        self.viewModel = viewModel
        self.viewController = ConnectionViewController(viewModel: viewModel)
        super.init()
        viewModel.coordinator = self
    }

    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func nextButtonDidTap() {
        listener?.nextButtonDidTap(self)
    }
}
