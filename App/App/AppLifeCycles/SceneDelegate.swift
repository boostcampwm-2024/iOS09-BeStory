//
//  SceneDelegate.swift
//  App
//
//  Created by jung on 11/4/24.
//

import Core
import Data
import Feature
import Interfaces
import P2PSocket
import UIKit
import UseCase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
    let container = MainContainer()
    var coordinator: Coordinator?
	
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let coordinator = container.coordinator()
        self.coordinator = coordinator
        coordinator.start(nil)
		let window = UIWindow(windowScene: windowScene)
        window.rootViewController = coordinator.viewController
        
		self.window = window
		window.makeKeyAndVisible()
	}
}
