//
//  SharedVideoEditCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import UIKit

protocol SharedVideoEditListener: AnyObject {
    func nextButtonDidTap(_ coordinator: SharedVideoEditCoordinatable)
}

final class SharedVideoEditCoordinator: Coordinator, SharedVideoEditCoordinatable {
    weak var listener: SharedVideoEditListener?

    private let viewController: SharedVideoEditViewController
    private let viewModel: SharedVideoEditViewModel

    init(viewModel: SharedVideoEditViewModel) {
        self.viewModel = viewModel
        self.viewController = SharedVideoEditViewController(viewModel: viewModel)
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
