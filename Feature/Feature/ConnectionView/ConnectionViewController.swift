//
//  ConnectionViewController.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import UIKit
import SnapKit
import Combine

final public class ConnectionViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: ConnectionViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private var centralCircleView = CircleView(style: .large)
    private var innerGrayCircleView = UIView()
    private var outerGrayCircleView = UIView()
    private var userContainerView = UIView()

    // MARK: - Initializer

    public init(viewModel: ConnectionViewModel) {
        self.viewModel = viewModel
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

        bind()

        viewModel.fetchUsers()
    }
}

// MARK: - Binding

private extension ConnectionViewController {
    func bind() {
        viewModel.$users
            .sink { [weak self] users in
                self?.updateUserCircleViews(users)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Objc Methods

@objc
private extension ConnectionViewController {
    func userDidTapped(_ sender: UITapGestureRecognizer) {
        guard let id = sender.view?.accessibilityLabel else { return }
        showAlert(
            title: "Invite",
            message: "초대하시겠습니까?",
            onConfirm: { self.viewModel.invite(id: id) }
        )
    }
}

// MARK: - Methods

private extension ConnectionViewController {
    func updateUserCircleViews(_ users: [BrowsingUser]) {
        for user in users {
            if user.state == .found {
                if viewModel.getCurrentPosition(id: user.id) != nil { continue }
                addUserCircleView(user: user, maxAttempts: users.count)
            } else if user.state == .lost {
                guard let currentPosition = viewModel.getCurrentPosition(id: user.id) else { continue }
                viewModel.removeCurrentPosition(id: user.id)
                removeUserCircleView(position: currentPosition)
            }
        }

        userContainerView.setNeedsLayout()
    }

    func addUserCircleView(user: BrowsingUser, maxAttempts: Int) {
        let center = view.center
        let innerDiameter = Constants.centralCircleViewSize
        let outerDiameter = Constants.outerGrayCircleViewSize

        let position = viewModel.getRandomPosition(
            innerDiameter: innerDiameter,
            outerDiameter: outerDiameter,
            center: center,
            maxAttempts: maxAttempts
        )

        viewModel.addCurrentPosition(id: user.id, position: position)

        let userCircleView = CircleView(style: .small)
        userCircleView.setupConfigure(emoji: viewModel.getRandomEmoji(), name: user.name)
        userContainerView.addSubview(userCircleView)

        userCircleView.snp.makeConstraints { make in
            make.center.equalTo(position)
            make.size.equalTo(Constants.userCircleViewSize)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapped(_:)))
        userCircleView.addGestureRecognizer(tapGesture)
        userCircleView.accessibilityLabel = user.id
    }

    func removeUserCircleView(position: CGPoint) {
        userContainerView.subviews.forEach {
            if $0.center == position {
                $0.removeFromSuperview()
            }
        }
    }

    func showAlert(title: String, message: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            onConfirm()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

// MARK: - UI Configure

private extension ConnectionViewController {
    enum Constants {
        static let centralCircleViewSize: CGFloat = 150
        static let centralCircleViewRadius: CGFloat = 75

        static let userCircleViewSize: CGFloat = 100

        static let grayCircleViewBorderWidth: CGFloat = 1

        static let innerGrayCircleViewSize: CGFloat = 250
        static let innerGrayCircleViewRadius: CGFloat = 125

        static let outerGrayCircleViewSize: CGFloat = 350
        static let outerGrayCircleViewRadius: CGFloat = 175

        static let userContainerViewSize: CGFloat = 450
    }

    func setupViewAttributes() {
        view.backgroundColor = .black

        setupCentralCircleView()
        setupGrayCircleViews()
        setupUserContainerView()
    }

    func setupCentralCircleView() {
        centralCircleView.setupConfigure(emoji: viewModel.getRandomEmoji(), name: "나")

        centralCircleView.layer.borderColor = UIColor.gray.cgColor
        centralCircleView.layer.borderWidth = Constants.grayCircleViewBorderWidth
        centralCircleView.layer.cornerRadius = Constants.centralCircleViewRadius
    }

    func setupGrayCircleViews() {
        innerGrayCircleView.layer.borderColor = UIColor.gray.cgColor
        innerGrayCircleView.layer.borderWidth = Constants.grayCircleViewBorderWidth
        innerGrayCircleView.layer.cornerRadius = Constants.innerGrayCircleViewRadius

        outerGrayCircleView.layer.borderColor = UIColor.gray.cgColor
        outerGrayCircleView.layer.borderWidth = Constants.grayCircleViewBorderWidth
        outerGrayCircleView.layer.cornerRadius = Constants.outerGrayCircleViewRadius
    }

    func setupUserContainerView() {
        userContainerView.backgroundColor = .clear
    }

    func setupViewHierarchies() {
        [
            centralCircleView,
            innerGrayCircleView,
            outerGrayCircleView,
            userContainerView
        ].forEach({
            view.addSubview($0)
        })
    }

    func setupViewConstraints() {
        centralCircleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constants.centralCircleViewSize)
        }

        innerGrayCircleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constants.innerGrayCircleViewSize)
        }

        outerGrayCircleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constants.outerGrayCircleViewSize)
        }

        userContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
