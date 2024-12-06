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
    
    private let previewContainer: PreviewContainable
    private var previewCoordinator: Coordinatable?

    private let viewModel: SharedVideoEditViewModel

    init(
        viewModel: SharedVideoEditViewModel,
        previewContainer: PreviewContainable
    ) {
        self.viewModel = viewModel
        self.previewContainer = previewContainer
        let viewController = SharedVideoEditViewController(viewModel: viewModel)
        super.init(viewController: viewController)
        viewModel.coordinator = self
    }

    override func start(_ navigationController: UINavigationController?) {
        super.start(navigationController)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func attachPreview() {
        guard previewCoordinator == nil else { return }
        
        let coordinator = previewContainer.coordinator(listener: self)
        addChild(coordinator)
        coordinator.start(navigationController)
        previewCoordinator = coordinator
    }
}

// MARK: - PreviewListener
extension SharedVideoEditCoordinator: PreviewListener { }
