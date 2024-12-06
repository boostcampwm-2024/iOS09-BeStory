//
//  ResultViewController.swift
//  Feature
//
//  Created by 디해 on 12/5/24.
//

import AVFoundation
import Core
import Combine
import UIKit
import SnapKit

public final class PreviewViewController: UIViewController {
    private let videoView = VideoPlayerView()
    private let saveButton = UIButton(type: .system)
    
    private let viewModel: PreviewViewModel
    private let input = PassthroughSubject<PreviewViewInput, Never>()
    var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: PreviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModelBinding()
        setupUIBinding()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        input.send(.loadPreview(size: videoView.frame.size))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Binding
private extension PreviewViewController {
    func setupViewModelBinding() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output.receive(on: DispatchQueue.main)
            .sink(with: self) { (owner, output) in
                switch output {
                case .loadedPreview(let playerItem):
                    owner.videoView.replaceVideo(playerItem: playerItem)
                case .videoSaved:
                    owner.navigateToResult()
                }
            }
            .store(in: &cancellables)
    }
    
    func setupUIBinding() {
        saveButton.bs.tap
            .sink(with: self) { owner, _ in
                owner.input.send(.saveVideo)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UI Configure
private extension PreviewViewController {
    func setupUI() {
        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
    }
    
    func setupViewAttributes() {
        view.backgroundColor = .black
        setupSaveButton()
    }
    
    func setupSaveButton() {
        saveButton.backgroundColor = .white
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 20)
        saveButton.layer.cornerRadius = 25
    }
    
    func setupViewHierarchies() {
        view.addSubviews(
            videoView,
            saveButton
        )
    }
    
    func setupViewConstraints() {
        videoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(500)
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(videoView.snp.bottom).offset(20)
            make.width.equalTo(160)
            make.height.equalTo(50)
        }
    }
}

// MARK: - Private Methods
private extension PreviewViewController {
    func navigateToResult() {
        let resultViewController = ResultViewController()
        
        navigationController?.pushViewController(resultViewController, animated: true)
    }
}
