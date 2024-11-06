//
//  RootViewController.swift
//  App
//
//  Created by jung on 11/4/24.
//

import Domain
import UIKit
import Feature

final class RootViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		print(#function)
        view.backgroundColor = .systemBackground
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let groupInfoViewController = GroupInfoViewController()
        addChild(groupInfoViewController)
        view.addSubview(groupInfoViewController.view)
        //didMove 메서드를 호출해야 ContinerVC.view.superView가 할당됨
        groupInfoViewController.didMove(toParent: self)
    }
}