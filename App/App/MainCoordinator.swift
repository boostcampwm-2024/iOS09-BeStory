//
//  MainCoordinator.swift
//  App
//
//  Created by jung on 12/6/24.
//

import Core
import Feature
import UIKit

public final class MainCoordinator: Coordinator {
    private var bottomNavigationController: UINavigationController?
    
    // MARK: - Coordinatables
    private let groupInfoContainer: GroupInfoContainable
    private var groupInfoCoordinatable: Coordinatable?
    
    private let connectionContainer: ConnectionContainable
    private var connectionCoordinatable: Coordinatable?
    
    // MARK: - Initializer
    public init(
        groupInfoContainer: GroupInfoContainable,
        connectionContainer: ConnectionContainable
    ) {
        self.groupInfoContainer = groupInfoContainer
        self.connectionContainer = connectionContainer
        super.init(viewController: MainViewController())
    }
    
    public override func start(_ navigationController: UINavigationController?) {
        guard let viewController = viewController as? MainViewController else { return }
        
        let topViewController = groupInfoViewController()
        let bottomViewController = connectionViewController()
        viewController.attachTopViewController(topViewController)
        viewController.attachBottomViewController(bottomViewController)
    }
}

private extension MainCoordinator {
    func connectionViewController() -> UIViewController {
        let coordinator = connectionContainer.coordinator(listener: self)
        connectionCoordinatable = coordinator
        let navigation = UINavigationController(rootViewController: coordinator.viewController)
        bottomNavigationController = navigation
        coordinator.start(navigation)
        
        return navigation
    }
    
    func groupInfoViewController() -> UIViewController {
        let coordinator = groupInfoContainer.coordinator(listener: self)
        groupInfoCoordinatable = coordinator
        let navigation = UINavigationController(rootViewController: coordinator.viewController)
        coordinator.start(navigation)
        
        return navigation
    }
}

// MARK: - ConnectionListener
extension MainCoordinator: ConnectionListener { }

// MARK: - GroupInfoListener
extension MainCoordinator: GroupInfoListener {
    public func exitGroupButtonDidTap() {
        FileSystemManager.shared.deleteAllFiles()
        bottomNavigationController?.popToRootViewController(animated: true)
        connectionCoordinatable?.start(bottomNavigationController)
    }
}
