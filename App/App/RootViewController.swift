//
//  RootViewController.swift
//  App
//
//  Created by jung on 11/4/24.
//

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
        let title = "iOS09 - 차은우원빈현빈장원영"
        let users = [
            "건우",
            "지혜",
            "석영"
        ].map { InvitedUser(id: $0, name: $0, state: .connected) }
        let groupInfoViewController = GroupInfoViewController(title: title, users: users)
        addChild(groupInfoViewController)
        view.addSubview(groupInfoViewController.view)
        //didMove 메서드를 호출해야 ContinerVC.view.superView가 할당됨
        groupInfoViewController.didMove(toParent: self)
    }
}
