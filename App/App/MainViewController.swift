//
//  MainViewController.swift
//  App
//
//  Created by jung on 12/6/24.
//

import SnapKit
import UIKit

final class MainViewController: UIViewController {
    private enum Constants {
        static let topViewHeight: CGFloat = 200
    }

    func attachTopViewController(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.backgroundColor = .red
        viewController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Constants.topViewHeight)
        }
    }
    
    func attachBottomViewController(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        viewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.topViewHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
