//
//  SceneDelegate.swift
//  App
//
//  Created by jung on 11/4/24.
//

import UIKit
import Feature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
        DIContainer.shared.registerDependency()

		let window = UIWindow(windowScene: windowScene)
        let connectionViewController = ConnectionViewController(
            viewModel: DIContainer.shared.resolve(type: ConnectionViewModel.self)
        )
        window.rootViewController = connectionViewController
		self.window = window
		window.makeKeyAndVisible()
	}
}
