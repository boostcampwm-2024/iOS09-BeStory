//
//  SharedVideoEditCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import UIKit

public protocol SharedVideoEditListener: AnyObject { }

final class SharedVideoEditCoordinator: Coordinator, SharedVideoEditCoordinatable {
    weak var listener: SharedVideoEditListener?

    private let viewModel: SharedVideoEditViewModel

    init(viewModel: SharedVideoEditViewModel) {
        self.viewModel = viewModel
        let viewController = SharedVideoEditViewController(viewModel: viewModel)
        super.init(viewController: viewController)
        viewModel.coordinator = self
    }

    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func nextButtonDidTap() { }
}
