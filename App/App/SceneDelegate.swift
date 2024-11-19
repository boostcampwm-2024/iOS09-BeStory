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
		
		let window = UIWindow(windowScene: windowScene)
        let viewModel = MultipeerVideoListViewModel()
        let rootViewController = VideoListViewController(viewModel: viewModel)
        window.rootViewController = rootViewController
		self.window = window
		window.makeKeyAndVisible()
	}
}
