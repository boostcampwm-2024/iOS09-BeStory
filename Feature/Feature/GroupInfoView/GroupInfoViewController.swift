//
//  File.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import SnapKit
import UIKit

final public class GroupInfoViewController: UIViewController {
    private let titleLabel = UILabel()
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
    
    public convenience init() {
        self.init(viewModel: GroupInfoViewModel())
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBind()
        input.send(.viewDidLoad)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewHierarchies()
        setupViewConstraints()
        setupViewAttributes()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init from nib is not supported".uppercased())
    }
    
    func setupBind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output.sink { [weak self] outputResult in
            switch outputResult {
            case .userStateDidChanged(let user):
                self?.updateInvitedUserState(user: user)
            case .userDidInvited(user: let user):
                self?.addInvitedUser(user: user)
            case .groupCountDidChanged(count: let count):
                self?.updateGroupCount(to: count)
            case .titleDidChanged(title: let title):
                self?.updateTitle(to: title)
            }
        }
        .store(in: &cancellables)
    }
}

private extension GroupInfoViewController {
    func setupViewHierarchies() {
        view.addSubview(titleLabel)
        view.addSubview(countView)
        view.addSubview(participantScrollView)
        view.addSubview(exitButton)
        participantScrollView.addSubview(participantStackView)
    }
    
    func setupViewConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.leading.equalToSuperview().offset(28)
        }
        countView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(titleLabel)
        }
        participantScrollView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(exitButton.snp.leading).offset(-8)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.height.equalTo(35)
        }
        exitButton.snp.makeConstraints {
            $0.height.equalTo(38)
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalTo(participantScrollView)
        }
        participantStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
    
    func setupViewAttributes() {
        view.backgroundColor = UIColor(red: 17/255, green: 24/255, blue: 38/255, alpha: 1)
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
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
    
    func addInvitedUser(user: InvitedUser) {
        participantStackView.addArrangedSubview(ParticipantInfoView(user: user))
    }
    
    func updateInvitedUserState(user: InvitedUser) {
        Task {
            participantStackView.arrangedSubviews.forEach {
                ($0 as? ParticipantInfoView)?.updateState(user: user)
            }
        }
    }
    
    func updateGroupCount(to count: Int) {
        countView.updateCount(to: count)
    }
    
    func updateTitle(to title: String) {
        self.title = title
        titleLabel.text = title
    }
}
