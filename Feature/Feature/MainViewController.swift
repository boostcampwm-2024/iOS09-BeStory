//
//  MainViewController.swift
//  Feature
//
//  Created by 이숲 on 11/21/24.
//

import Combine
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

        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
    }
}

// MARK: - UI Configure

private extension MainViewController {
    enum Constants {
        static let topViewCornerRadius: CGFloat = 10

        static let topViewTopOffset: CGFloat = 20
        static let topViewLeadingOffset: CGFloat = 20
        static let topViewTrailingOffset: CGFloat = -20
        static let topViewHeight: CGFloat = 120
    }

    func setupViewAttributes() {
        topViewController.view.layer.cornerRadius = Constants.topViewCornerRadius
        topViewController.view.clipsToBounds = true
    }

    func setupViewHierarchies() {
        [
            bottomNavigationController,
            topViewController
        ].forEach({
            addChild($0)
            view.addSubview($0.view)
            $0.didMove(toParent: self)
        })
    }

    func setupViewConstraints() {
        bottomNavigationController.view.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        topViewController.view.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.topViewTopOffset)
            $0.leading.equalToSuperview().offset(Constants.topViewLeadingOffset)
            $0.trailing.equalToSuperview().offset(Constants.topViewTrailingOffset)
            $0.height.equalTo(Constants.topViewHeight)
        }
    }
}
