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

    public var onNextButton: (() -> Void)?

    private let viewModel: ConnectionViewModel
    private let input = PassthroughSubject<ConnectionViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private var centralCircleView = CircleView(style: .large)
    private var innerGrayCircleView = UIView()
    private var outerGrayCircleView = UIView()
    private var userContainerView = UIView()
    private var nextButton = UIButton(type: .system)
    private var currentAlert: UIAlertController?

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

extension ConnectionViewController {
    func setupBind() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                    // Connection Output

                case .found(let user, let position, let emoji):
                    let position = CGPoint(x: position.0, y: position.1)
                    addUserCircleView(user: user, position: position, emoji: emoji)
                case .lost(let user, let position):
                    let position = CGPoint(x: position.0, y: position.1)
                    removeUserCircleView(user: user, position: position)

                    // Invitation Output

                case .invited(let invitingUser, let position):
                    showAlertWithActions(
                        title: invitingUser.name,
                        message: "초대를 수락하시겠습니까?",
                        onConfirm: {
                            self.input.send(.accept)
                            self.closeCurrentAlert()

                            let position = CGPoint(x: position.0, y: position.1)
                            self.removeUserCircleView(user: invitingUser, position: position)
                        },
                        onCancel: {
                            self.input.send(.reject)
                            self.closeCurrentAlert()
                        }
                    )
                case .accepted(let invitedUser, let position):
                    self.closeCurrentAlert()

                    showAlertWithActions(
                        title: "Accepted",
                        message: "상대방(\(invitedUser.name))이 초대를 수락했습니다.",
                        onConfirm: { self.closeCurrentAlert() },
                        onCancel: { self.closeCurrentAlert() }
                    )
                    let position = CGPoint(x: position.0, y: position.1)
                    self.removeUserCircleView(user: invitedUser, position: position)
                case .rejected(let userName):
                    self.closeCurrentAlert()

                    showAlertWithActions(
                        title: "Rejected",
                        message: "상대방(\(userName))이 초대를 거절했습니다.",
                        onConfirm: { self.closeCurrentAlert() },
                        onCancel: { self.closeCurrentAlert() }
                    )
                case .timeout:
                    guard let alert = currentAlert else { return }
                    alert.dismiss(animated: true)
                    self.currentAlert = nil

                    showAlertWithActions(
                        title: "Timeout",
                        message: "응답 시간이 초과되었습니다.",
                        onConfirm: { self.closeCurrentAlert() },
                        onCancel: { self.closeCurrentAlert() }
                    )
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
        showAlertWithActions(
            title: "Invite",
            message: "초대하시겠습니까?",
            onConfirm: {
                self.input.send(.invite(id: id))
                self.closeCurrentAlert()

                self.showAlertWithoutActions(
                    title: "Waiting",
                    message: "상대방의 응답을 기다리는 중입니다."
                )
            },
            onCancel: { self.closeCurrentAlert() }
        )
    }

    func nextButtonDidTapped() {
        onNextButton?()
    }
}

// MARK: - Methods

private extension ConnectionViewController {
    func addUserCircleView(user: BrowsedUser, position: CGPoint, emoji: String) {
        let userCircleView = CircleView(style: .small)
        userCircleView.configure(emoji: emoji, name: user.name)

        userContainerView.addSubview(userCircleView)

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

    func showAlertWithActions(
        title: String,
        message: String,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            onConfirm()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            onCancel()
        }

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
        currentAlert = alert
    }

    func showAlertWithoutActions(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        present(alert, animated: true)
        currentAlert = alert
    }

    func closeCurrentAlert() {
        guard let alert = currentAlert else { return }
        alert.dismiss(animated: true)
        currentAlert = nil
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

        static let nextButtonBackgroundColor: UIColor = UIColor(red: 31/255, green: 41/255, blue: 55/255, alpha: 1)
        static let nextButtonTextColor: UIColor = .white
        static let nextButtonFontSize: CGFloat = 20
        static let nextButtonCornerRadius: CGFloat = 10
        static let nextButtonBottomOffset: CGFloat = -20
        static let nextButtonWidth: CGFloat = 120
        static let nextButtonHeight: CGFloat = 50
    }

    func setupViewAttributes() {
        view.backgroundColor = .black

        setupCentralCircleView()
        setupGrayCircleViews()
        setupUserContainerView()
        setupNextButton()
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

    func setupNextButton() {
        nextButton.backgroundColor = Constants.nextButtonBackgroundColor
        nextButton.setTitle("편집하기", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: Constants.nextButtonFontSize)
        nextButton.layer.cornerRadius = Constants.nextButtonCornerRadius
        nextButton.addTarget(self, action: #selector(nextButtonDidTapped), for: .touchUpInside)
    }

    func setupViewHierarchies() {
        [
            centralCircleView,
            innerGrayCircleView,
            outerGrayCircleView,
            userContainerView,
            nextButton
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

        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(Constants.nextButtonBottomOffset)
            make.width.equalTo(Constants.nextButtonWidth)
            make.height.equalTo(Constants.nextButtonHeight)
        }
    }
}
