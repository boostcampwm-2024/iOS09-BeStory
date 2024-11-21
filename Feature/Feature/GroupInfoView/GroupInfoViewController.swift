//
//  File.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import Entity
import SnapKit
import UIKit

final public class GroupInfoViewController: UIViewController {
    private let countView = ParticipantCountView()
    private let participantStackView = UIStackView()
    private let participantScrollView = UIScrollView()
    private let exitButton = UIButton()
    
    var input = PassthroughSubject<GroupInfoViewModel.Input, Never>()
    var viewModel: GroupInfoViewModel
    var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: GroupInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchies()
        setupViewConstraints()
        setupBind()
        input.send(.viewDidLoad)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewAttributes()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init from nib is not supported".uppercased())
    }
    
    func setupBind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] outputResult in
            switch outputResult {
            case .userStateDidChanged(let user):
                self?.updateInvitedUserState(user: user)
            case .userDidInvited(user: let user):
                self?.addInvitedUser(user: user)
            case .groupCountDidChanged(count: let count):
                self?.updateGroupCount(to: count)
            case .userDidExit(user: let user):
                self?.removeUserInfo(user: user)
            }
        }
        .store(in: &cancellables)
    }
}

private extension GroupInfoViewController {
    func setupViewHierarchies() {
        view.addSubview(countView)
        view.addSubview(participantScrollView)
        view.addSubview(exitButton)
        exitButton.isEnabled = false
        participantScrollView.addSubview(participantStackView)
    }
    
    func setupViewConstraints() {
        countView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(20)
        }
        participantScrollView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(exitButton.snp.leading).offset(-8)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(35)
        }
        exitButton.snp.makeConstraints {
            $0.top.equalTo(countView.snp.bottom).offset(10)
            $0.height.equalTo(38)
            $0.trailing.equalToSuperview().inset(14)
        }
        participantStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
    
    func setupViewAttributes() {
        view.backgroundColor = UIColor(red: 17/255, green: 24/255, blue: 38/255, alpha: 1)
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .small
        buttonConfig.title = "나가기"
        buttonConfig.titlePadding = 4
        buttonConfig.baseBackgroundColor = UIColor(red: 244/255,
                                                   green: 244/255,
                                                   blue: 245/255,
                                                   alpha: 1)
        buttonConfig.baseForegroundColor = UIColor(red: 64/255,
                                                   green: 64/255,
                                                   blue: 66/255,
                                                   alpha: 1)
        buttonConfig.cornerStyle = .large
        exitButton.configuration = buttonConfig
        
        participantScrollView.backgroundColor = .clear
        participantScrollView.showsVerticalScrollIndicator = false
        participantScrollView.showsHorizontalScrollIndicator = false
        participantScrollView.layer.cornerRadius = 4
        participantStackView.axis = .horizontal
        participantStackView.spacing = 14
    }
    
    func addInvitedUser(user: ConnectedUser) {
        participantStackView.addArrangedSubview(ParticipantInfoView(user: user))
    }
    
    func updateInvitedUserState(user: ConnectedUser) {
        participantStackView.arrangedSubviews
            .compactMap { $0 as? ParticipantInfoView }
            .first(where: { (view: ParticipantInfoView) in
                view.user.id == user.id
            })?
            .updateState(user.state)
    }
    
    func removeUserInfo(user: ConnectedUser) {
        participantStackView.arrangedSubviews
            .compactMap { $0 as? ParticipantInfoView }
            .first(where: {
                $0.user.id == user.id
            })?
            .removeFromSuperview()
    }
    
    func updateGroupCount(to count: Int) {
        countView.updateCount(to: count)
    }
}
