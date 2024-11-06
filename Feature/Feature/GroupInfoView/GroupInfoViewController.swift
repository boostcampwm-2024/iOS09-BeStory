//
//  File.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import DomainInterface
import SnapKit
import UIKit

final public class GroupInfoViewController: UIViewController, ViewProtocol {
    private let titleLabel = UILabel()
    let countView = ParticipantCountView()
    let participantStackView = UIStackView()
    
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
        input.send(.viewDidLoad)
        setupBind()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewHierarchies()
        setupViewConstraints()
        setupViewAttributes()
    }
    
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
        view.addSubview(participantStackView)
    }
    
    func setupViewConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().offset(28)
        }
        countView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalTo(titleLabel)
        }
        participantStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        view.snp.makeConstraints {
            $0.bottom.equalTo(participantStackView.snp.bottom).offset(8)
        }
        guard let superView = view.superview else { return }
        view.snp.makeConstraints {
            $0.top.left.right.equalTo(superView.safeAreaLayoutGuide)
        }
    }
    
    func setupViewAttributes() {
        titleLabel.text = title
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

protocol ViewProtocol {
    associatedtype Input
    associatedtype ViewModelType: ViewModelProtocol where ViewModelType.Input == Input
    
    var input: PassthroughSubject<Input, Never> { get set }
    var viewModel: ViewModelType { get set }
    var cancellables: Set<AnyCancellable> { get set }
    
    func setupBind()
}
