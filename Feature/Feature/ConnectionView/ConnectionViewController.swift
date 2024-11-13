//
//  ConnectionViewController.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import Combine
import Entity
import SnapKit
import UIKit

final public class ConnectionViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: ConnectionViewModel
    private let input = PassthroughSubject<ConnectionInput, Never>()
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
        setupBind()

        viewModel.configure(
            centerPosition: (view.center.x, view.center.y),
            innerDiameter: Float(Constants.centralCircleViewSize),
            outerDiameter: Float(Constants.outerGrayCircleViewSize)
        )

        input.send(.fetchUsers)
    }
}

// MARK: - Binding

extension ConnectionViewController: ViewBindable {
    typealias Output = ConnectionOutput

    func setupBind() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output.sink { [weak self] result in
            switch result {
            case .found(let user, let position, let emoji):
                let position = CGPoint(x: position.0, y: position.1)
                self?.addUserCircleView(user: user, position: position, emoji: emoji)
            case .lost(let user, let position):
                let position = CGPoint(x: position.0, y: position.1)
                self?.removeUserCircleView(user: user, position: position)
            case .none:
                break
            }
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
            onConfirm: { self.input.send(.invite(id: id)) }
        )
    }
}

// MARK: - Methods

private extension ConnectionViewController {
    func addUserCircleView(user: BrowsedUser, position: CGPoint, emoji: String) {
        let userCircleView = CircleView(style: .small)
        userCircleView.configure(emoji: emoji, name: user.name)

        userCircleView.snp.makeConstraints { make in
            make.center.equalTo(position)
            make.size.equalTo(Constants.userCircleViewSize)
        }

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(userDidTapped(_:))
        )
        userCircleView.addGestureRecognizer(tapGesture)
        userCircleView.accessibilityLabel = user.id

        userContainerView.addSubview(userCircleView)
        userContainerView.layoutIfNeeded()
    }

    func removeUserCircleView(user: BrowsedUser, position: CGPoint) {
        userContainerView.subviews.forEach {
            if $0.center == position {
                $0.removeFromSuperview()
            }
        }
        userContainerView.layoutIfNeeded()
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
        centralCircleView.configure(emoji: "😎", name: "나")

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
