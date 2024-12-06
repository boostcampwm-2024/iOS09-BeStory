//
//  PreviewCoordinator.swift
//  Feature
//
//  Created by jung on 12/6/24.
//

import Core
import UIKit

public protocol PreviewListener: AnyObject { }

final class PreviewCoordinator: Coordinator, PreviewCoordinatable {
    weak var listener: PreviewListener?

    private let viewModel: PreviewViewModel

    init(viewModel: PreviewViewModel) {
        self.viewModel = viewModel
        let viewController = PreviewViewController(viewModel: viewModel)
        super.init(viewController: viewController)
        viewModel.coordinator = self
    }

    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func nextButtonDidTap() { }
}
