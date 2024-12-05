//
//  ConnectionViewController.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import Combine
import Core
import Entity
import SnapKit
import UIKit

final public class ConnectionViewController: UIViewController {
    // MARK: - Properties
    
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
    private var currentUserId: String?
    
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
        
        input.send(.fetchUsers)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !viewModel.compareCenter(currentCenter: view.center) else { return }
        viewModel.configure(
            centerPosition: view.center,
            innerRadius: Constants.centralCircleViewRadius,
            outerRadius: Constants.outerGrayCircleViewRadius
        )
    }
}

// MARK: - Binding

extension ConnectionViewController {
    func setupBind() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                        // Connection Output
                    case .foundUser(let user, let position, let emoji):
                        owner.addUserCircleView(user: user, position: position, emoji: emoji)
                    case .lostUser(let user):
                        owner.removeUserCircleView(user: user)
                        owner.resetCurrentAlert()
                        if user.id == owner.currentUserId {
                            owner.resetCurrentUserId()
                            owner.input.send(.rejectInvitation)
                        }
                        // Invitation Output
                    case .invitationReceivedBy(let user):
                        owner.presentInvitationReceivedAlert(by: user)
                    case .invitationAcceptedBy(let user):
                        owner.resetCurrentAlert()
                        owner.removeUserCircleView(user: user)
                        owner.presentInvitationAcceptedAlert(by: user)
                    case .invitationRejectedBy(let userName):
                        owner.resetCurrentAlert()
                        owner.presentInvitationRejectedAlert(by: userName)
                    case .invitationTimeout:
                        owner.resetCurrentAlert()
                        owner.invitationTimeoutAlert()
                       
                    case .openSharedVideoList:
                        owner.openVideoList()
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
        present(UIAlertController(type: .requestInvitation, actions: [
            .confirm(handler: {
                self.input.send(.inviteUser(id: id))
                let alert = UIAlertController(
                    title: "Waiting",
                    message: "상대방의 응답을 기다리는 중입니다.",
                    preferredStyle: .alert
                )
                self.setCurrentAlertAndUserId(alert: alert)
                self.present(alert, animated: true)
            }),
            .cancel()]
        ), animated: true)
    }
    
    func nextButtonDidTapped() {
        input.send(.nextButtonDidTapped)
    }
}

// MARK: - Private Methods
private extension ConnectionViewController {
    func addUserCircleView(user: BrowsedUser, position: CGPoint, emoji: String) {
        let userCircleView = CircleView(id: user.id, style: .small)
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
    
    func removeUserCircleView(user: BrowsedUser) {
        userContainerView.subviews
            .compactMap { $0 as? CircleView }
            .filter { $0.id == user.id }
            .forEach { $0.removeFromSuperview() }
        
        userContainerView.layoutIfNeeded()
    }
    
    func setCurrentAlertAndUserId(alert: UIAlertController, userId: String? = nil) {
        currentAlert = alert
        currentUserId = userId
    }
    
    func resetCurrentAlert() {
        guard let alert = currentAlert else { return }
        alert.dismiss(animated: true)
        currentAlert = nil
    }
    
    func resetCurrentUserId() {
        currentUserId = nil
    }
    
    func openVideoList() {
        let videoListViewController = VideoListViewController(
            viewModel: DIContainer.shared.resolve(type: MultipeerVideoListViewModel.self)
        )
        guard navigationController?.viewControllers.last === self else { return }
        self.navigationController?.pushViewController(videoListViewController, animated: true)
    }
    
    func presentInvitationReceivedAlert(by user: BrowsedUser) {
        let alert = UIAlertController(
            type: .invitationReceivedBy(name: user.name),
            actions: [
                .confirm(handler: {
                    self.input.send(.acceptInvitation(user: user))
                    self.resetCurrentAlert()
                    self.resetCurrentUserId()
                    self.removeUserCircleView(user: user)}),
                .cancel(handler: {
                    self.input.send(.rejectInvitation)
                    self.resetCurrentAlert()
                    self.resetCurrentUserId()})
            ])
        setCurrentAlertAndUserId(alert: alert, userId: user.id)
        present(alert, animated: true)
    }
    
    func presentInvitationAcceptedAlert(by user: BrowsedUser) {
        present(UIAlertController(
            type: .invitationAcceptedBy(name: user.name),
            actions: [.confirm(), .cancel()]), animated: true)
    }
    
    func presentInvitationRejectedAlert(by userName: String) {
        present(UIAlertController(
            type: .invitationRejectedBy(name: userName),
            actions: [.confirm(), .cancel()]), animated: true)
    }
    
    func invitationTimeoutAlert() {
        present(UIAlertController(
            type: .invitationTimeout,
            actions: [.confirm(), .cancel()]), animated: true)
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
        
        static let nextButtonFontSize: CGFloat = 20
        static let nextButtonCornerRadius: CGFloat = 25
        static let nextButtonBottomOffset: CGFloat = -50
        static let nextButtonWidth: CGFloat = 160
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
        nextButton.backgroundColor = .white
        nextButton.setTitle("편집하기", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
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
