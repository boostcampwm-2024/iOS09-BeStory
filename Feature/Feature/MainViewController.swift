//
//  MainViewController.swift
//  Feature
//
//  Created by 이숲 on 11/21/24.
//

import SnapKit
import UIKit

public final class MainViewController: UIViewController {
    // MARK: - UI Components

    private let topViewController: UIViewController
    private let bottomNavigationController: UINavigationController

    // MARK: - Initializer

    public init(topViewController: UIViewController, initialViewController: UIViewController) {
        self.topViewController = topViewController
        self.bottomNavigationController = UINavigationController(rootViewController: initialViewController)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchies()
        setupViewConstraints()
    }
}

// MARK: - UI Configure

private extension MainViewController {
    enum Constants {
        static let topViewHeight: CGFloat = 120
    }

    func setupViewHierarchies() {
        [
            topViewController,
            bottomNavigationController
        ].forEach({
            addChild($0)
            view.addSubview($0.view)
            $0.didMove(toParent: self)
        })
    }

    func setupViewConstraints() {
        topViewController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Constants.topViewHeight)
        }

        bottomNavigationController.view.snp.makeConstraints { make in
            make.top.equalTo(topViewController.view.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
