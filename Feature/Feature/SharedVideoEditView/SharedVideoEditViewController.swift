//
//  SharedVideoEditViewController.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import Combine
import SnapKit
import UIKit

public final class SharedVideoEditViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: SharedVideoEditViewModel
    private let input = PassthroughSubject<SharedVideoEditViewInput, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let videoPlayerView = VideoPlayerView()
    private var videoTimelineCollectionView: UICollectionView!
    private var videoTimelineDataSource: VideoTimelineDataSource!

    // MARK: - Initializer

    public init(viewModel: SharedVideoEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()

        setupViewBinding()

        loadInitialData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: - Binding

private extension SharedVideoEditViewController {
    func setupViewBinding() {
        let output = viewModel.transform(input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { output in
            }
            .store(in: &cancellables)
    }
}

// MARK: - UI Configure

private extension SharedVideoEditViewController {
    enum VideoPlayerViewConstants {
        static let topMargin: CGFloat = 14
        static let playerViewRatio: CGFloat = 9 / 16
    }

    enum VideoTimelineCollectionViewConstants {
        static let backgroundColor = UIColor(
            red: 31/255,
            green: 41/255,
            blue: 55/255,
            alpha: 1
        )
        static let spacing: CGFloat = 10
        static let topMargin: CGFloat = 14 + 80
        static let height: CGFloat = 120
        static let itemSize: CGSize = .init(width: 160, height: 90)
    }

    func setupViewAttributes() {
        view.backgroundColor = .black
        setupVideoTimelineCollectionView()
    }

    func setupVideoTimelineCollectionView() {
        let layout = setupLayout()
        videoTimelineCollectionView = .init(frame: .zero, collectionViewLayout: layout)

        videoTimelineCollectionView.backgroundColor = VideoTimelineCollectionViewConstants.backgroundColor
        videoTimelineCollectionView.showsHorizontalScrollIndicator = false
        videoTimelineCollectionView.dragInteractionEnabled = true

        let dataSource = setupDataSource()
        self.videoTimelineDataSource = dataSource
        videoTimelineCollectionView.dataSource = dataSource

        videoTimelineCollectionView.register(
            VideoTimelineCollectionViewCell.self,
            forCellWithReuseIdentifier: VideoTimelineCollectionViewCell.reuseIdentifier
        )
    }

    func setupViewHierarchies() {
        [
            videoPlayerView,
            videoTimelineCollectionView
        ].forEach({
            view.addSubview($0)
        })
    }
    
    func setupViewConstraints() {
        videoPlayerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(VideoPlayerViewConstants.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(videoPlayerView.snp.width).multipliedBy(VideoPlayerViewConstants.playerViewRatio)
        }

        videoTimelineCollectionView.snp.makeConstraints {
            $0.top.equalTo(videoPlayerView.snp.bottom).offset(VideoTimelineCollectionViewConstants.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(VideoTimelineCollectionViewConstants.height)
        }
    }
}

// MARK: - UICollectionView Methods

private extension SharedVideoEditViewController {
    func setupLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = VideoTimelineCollectionViewConstants.spacing
        layout.itemSize = VideoTimelineCollectionViewConstants.itemSize
        return layout
    }

    func setupDataSource() -> VideoTimelineDataSource {
        let dataSource = VideoTimelineDataSource(
            collectionView: videoTimelineCollectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VideoTimelineCollectionViewCell.reuseIdentifier,
                for: indexPath
            )
            guard let cell = cell as? VideoTimelineCollectionViewCell
            else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        }
        return dataSource
    }

    func applySnapShot(with items: [VideoTimelineItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<VideoTimelineSection, VideoTimelineItem>()
        snapshot.appendSections([.timeline])
        snapshot.appendItems(items, toSection: .timeline)

        videoTimelineDataSource.apply(snapshot, animatingDifferences: true)
    }

    func reload(with videos: [VideoTimelineItem]) {
        applySnapShot(with: videos)
    }

    // TEST 용 메서드 입니다.
    func loadInitialData() {
        let items = [
            VideoTimelineItem(
                thumbnailImage: Data(),
                duration: "0:0"
            ),
            VideoTimelineItem(
                thumbnailImage: Data(),
                duration: "10:0"
            ),
            VideoTimelineItem(
                thumbnailImage: Data(),
                duration: "20:0"
            ),
            VideoTimelineItem(
                thumbnailImage: Data(),
                duration: "30:0"
            ),
            VideoTimelineItem(
                thumbnailImage: Data(),
                duration: "40:0"
            )
        ]

        applySnapShot(with: items)
    }
}

// MARK: - UICollectionViewDelegate
