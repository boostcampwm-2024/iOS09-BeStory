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
	enum Mode {
		case `default`
		case edite(EditingMode)
	}
	
	enum EditingMode {
		case videoTrimming
	}
	
    // MARK: - Properties

    private let viewModel: SharedVideoEditViewModel
    private let input = PassthroughSubject<SharedVideoEditViewInput, Never>()
    private var cancellables = Set<AnyCancellable>()
	private var mode: Mode = .default {
		didSet { setupUI(for: mode) }
	}

    // MARK: - UI Components

    private let videoPlayerView = VideoPlayerView()
    private var videoTimelineCollectionView: UICollectionView!
	private let editButtonView = UIView()
	private let editSaveButton = UIButton()
	private let editCancelButton = UIButton()
	private let middleContainerView = UIView()
	private let optionButtonStackView = OptionButtonStackView()
	private let videoTrimmingSliderBar = VideoTrimmingSliderBar()
	
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

		setupUI()
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
	enum EditButtonViewConstants {
		static let topMargin: CGFloat = 14
		static let sideMargin: CGFloat = 12
		static let height: CGFloat = 40
	}
	
	enum SaveAndCancelButtonConstants {
		static let width = 60
	}
	
    enum VideoPlayerViewConstants {
        static let topMargin: CGFloat = 14
        static let playerViewRatio: CGFloat = 9 / 16
    }
	
	enum MiddleContainerViewConstants {
		static let topMargin: CGFloat = 22
		static let sideMargin: CGFloat = 24
		static let height: CGFloat = 50
	}

    enum VideoTimelineCollectionViewConstants {
        static let backgroundColor = UIColor(
            red: 31/255,
            green: 41/255,
            blue: 55/255,
            alpha: 1
        )
        static let spacing: CGFloat = 10
        static let topMargin: CGFloat = 14
        static let height: CGFloat = 120
        static let itemSize: CGSize = .init(width: 160, height: 90)
    }
	
	func setupUI() {
		setupViewAttributes()
		setupViewHierarchies()
		setupViewConstraints()
		setupUI(for: mode)
	}

    func setupViewAttributes() {
        view.backgroundColor = .black
		setupEditSaveButton()
		setupEditCancelButton()
        setupVideoTimelineCollectionView()
    }
	
	func setupEditCancelButton() {
		editCancelButton.setTitle("취소", for: .normal)
		editCancelButton.setTitleColor(.red, for: .normal)
	}
	
	func setupEditSaveButton() {
		editSaveButton.setTitle("저장", for: .normal)
		editSaveButton.setTitleColor(.blue, for: .normal)
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
		view.addSubviews(
			editButtonView,
			videoPlayerView,
			videoTimelineCollectionView,
			editButtonView,
			middleContainerView
		)
		editButtonView.addSubviews(editCancelButton, editSaveButton)
		middleContainerView.addSubviews(optionButtonStackView, videoTrimmingSliderBar)
    }
    
    func setupViewConstraints() {
		editButtonView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(EditButtonViewConstants.sideMargin)
			$0.top.equalTo(view.safeAreaLayoutGuide).offset(EditButtonViewConstants.topMargin)
			$0.height.equalTo(EditButtonViewConstants.height)
		}
		
		editSaveButton.snp.makeConstraints {
			$0.trailing.top.bottom.equalToSuperview()
			$0.width.equalTo(SaveAndCancelButtonConstants.width)
		}
		
		editCancelButton.snp.makeConstraints {
			$0.leading.top.bottom.equalToSuperview()
			$0.width.equalTo(SaveAndCancelButtonConstants.width)
		}
		
        videoPlayerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(VideoPlayerViewConstants.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(videoPlayerView.snp.width).multipliedBy(VideoPlayerViewConstants.playerViewRatio)
        }
		
		middleContainerView.snp.makeConstraints {
			$0.top.equalTo(videoPlayerView.snp.bottom).offset(MiddleContainerViewConstants.topMargin)
			$0.leading.trailing.equalToSuperview().inset(MiddleContainerViewConstants.sideMargin)
			$0.height.equalTo(MiddleContainerViewConstants.height)
		}

		optionButtonStackView.snp.makeConstraints {
			$0.leading.centerY.equalToSuperview()
			$0.trailing.lessThanOrEqualToSuperview()
		}
		
		videoTrimmingSliderBar.snp.makeConstraints {
			$0.leading.trailing.top.equalToSuperview()
			$0.height.equalToSuperview()
		}

        videoTimelineCollectionView.snp.makeConstraints {
			$0.top.equalTo(middleContainerView.snp.bottom).offset(VideoTimelineCollectionViewConstants.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(VideoTimelineCollectionViewConstants.height)
        }
    }
	
	func setupUI(for mode: Mode) {
		switch mode {
			case .default: setupDefaultModeUI()
			case let .edite(editingMode): setupEditingModeUI(for: editingMode)
		}
	}
	
	func setupDefaultModeUI() {
		videoPlayerView.isHiddenSliderBar = false
		optionButtonStackView.isHidden = false
		videoTrimmingSliderBar.isHidden = true
		editButtonView.isHidden = true
		
		videoPlayerView.snp.updateConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).offset(VideoPlayerViewConstants.topMargin)
		}
	}
	
	func setupEditingModeUI(for mode: EditingMode) {
		videoPlayerView.isHiddenSliderBar = true
		optionButtonStackView.isHidden = true
		editButtonView.isHidden = false
		
		let topMargin = VideoPlayerViewConstants.topMargin + EditButtonViewConstants.height
		videoPlayerView.snp.updateConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).offset(topMargin)
		}
		
		switch mode {
			case .videoTrimming: setupTrimmingVideoModeUI()
		}
	}
	
	func setupTrimmingVideoModeUI() {
		videoTrimmingSliderBar.isHidden = false
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
