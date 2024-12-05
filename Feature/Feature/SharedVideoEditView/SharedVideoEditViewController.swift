//
//  SharedVideoEditViewController.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import Combine
import Core
import SnapKit
import UIKit

public final class SharedVideoEditViewController: UIViewController {
	enum Mode {
		case `default`
		case edit(EditingMode)
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
    private var nextButton = UIButton(type: .system)

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
        
        input.send(.viewDidLoad)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: - Binding
private extension SharedVideoEditViewController {
	func setupViewBinding() {
		setupViewModelBinding()
		setupUIBinding()
	}
	
    func setupViewModelBinding() {
        let output = viewModel.transform(input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink(with: self) { (owner, output) in
                switch output {
                case .timelineItemsDidChanged(let items):
                    owner.reload(with: items)
                case .sliderModelDidChanged(let model):
                    owner.videoTrimmingSliderBar.configure(with: model)
                }
            }
            .store(in: &cancellables)
    }
	
	func setupUIBinding() {
		optionButtonStackView.bs.videoTrimmingButtonDidTapped
			.sink(with: self) { owner, _ in
				owner.mode = .edit(.videoTrimming)
			}
			.store(in: &cancellables)
		
		editSaveButton.bs.tap
			.sink(with: self) { owner, _ in
                owner.input.send(.sliderEditSaveButtonDidTapped)
				owner.mode = .default
			}
			.store(in: &cancellables)
		
		editCancelButton.bs.tap
			.sink(with: self) { owner, _ in
				owner.presentCancelAlertViewController()
			}
			.store(in: &cancellables)
        
        nextButton.bs.tap
            .sink(with: self) { owner, _ in
                owner.navigateToPreview()
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
        static let topMargin: CGFloat = 22
        static let height: CGFloat = 120
        static let itemSize: CGSize = .init(width: 160, height: 90)
    }

    enum NextButtonConstants {
        static let fontSize: CGFloat = 20
        static let cornerRadius: CGFloat = 25
        static let bottomOffset: CGFloat = -50
        static let width: CGFloat = 160
        static let height: CGFloat = 50
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
        setupVideoTrimmingSliderBar()
        setupNextButton()
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
        videoTimelineCollectionView.delegate = self
        videoTimelineCollectionView.dragDelegate = self
        videoTimelineCollectionView.dropDelegate = self
        videoTimelineCollectionView.dragInteractionEnabled = true

        videoTimelineCollectionView.register(
            VideoTimelineCollectionViewCell.self,
            forCellWithReuseIdentifier: VideoTimelineCollectionViewCell.reuseIdentifier
        )
    }

    func setupVideoTrimmingSliderBar() {
        videoTrimmingSliderBar.delegate = self
    }

    func setupNextButton() {
        nextButton.backgroundColor = .white
        nextButton.setTitle("미리보기", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: NextButtonConstants.fontSize)
        nextButton.layer.cornerRadius = NextButtonConstants.cornerRadius
    }

    func setupViewHierarchies() {
		view.addSubviews(
			editButtonView,
			videoPlayerView,
			videoTimelineCollectionView,
			editButtonView,
			middleContainerView,
            nextButton
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

        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(NextButtonConstants.bottomOffset)
            $0.width.equalTo(NextButtonConstants.width)
            $0.height.equalTo(NextButtonConstants.height)
        }
    }
	
	func setupUI(for mode: Mode) {
		switch mode {
			case .default: setupDefaultModeUI()
			case let .edit(editingMode): setupEditingModeUI(for: editingMode)
		}
	}
	
	func setupDefaultModeUI() {
		videoPlayerView.isHiddenSliderBar = false
		optionButtonStackView.isHidden = false
		videoTrimmingSliderBar.isHidden = true
		editButtonView.isHidden = true
        nextButton.isHidden = false

		videoPlayerView.snp.updateConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).offset(VideoPlayerViewConstants.topMargin)
		}
	}
	
	func setupEditingModeUI(for mode: EditingMode) {
		videoPlayerView.isHiddenSliderBar = true
		optionButtonStackView.isHidden = true
		editButtonView.isHidden = false
        nextButton.isHidden = true

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
}

// MARK: - VideoTrimmingSliderBarDelegate
extension SharedVideoEditViewController: VideoTrimmingSliderBarDelegate {
	func lowerValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double) {
        input.send(.sliderModelLowerValueDidChanged(value: value))
    }
	
	func upperValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double) {
        input.send(.sliderModelUpperValueDidChanged(value: value))
    }
	
    func playerValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double) {
        videoPlayerView.updateVideoTime(with: value)
    }
}

// MARK: - Private Methods
private extension SharedVideoEditViewController {
	func presentCancelAlertViewController() {
        present(UIAlertController(
            type: .custom(
                title: "Cancel Editing",
                message: "편집을 취소하게 되면, 편집된 내용은 삭제됩니다. 그래도 취소하시겠습니까?"),
            actions: [
                .confirm(handler: { [weak self] in
                    self?.mode = .default
                }),
                .cancel()]
        ), animated: true)
	}
    
    func navigateToPreview() {
        let previewViewController = PreviewViewController(
            viewModel: DIContainer.shared.resolve(type: PreviewViewModel.self)
        )
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension SharedVideoEditViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let selectedItem = videoTimelineDataSource.itemIdentifier(for: indexPath),
              let selectedCell = collectionView.cellForItem(at: indexPath)
        else { return }
        
        selectedCell.isSelected = true
        videoPlayerView.replaceVideo(url: selectedItem.url)
        input.send(.timelineCellDidTap(url: selectedItem.url))
    }
}

extension SharedVideoEditViewController: UICollectionViewDragDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: any UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard let item = videoTimelineDataSource.itemIdentifier(for: indexPath),
              let jsonString = item.toJSONString() else { return [] }
        let itemProvider = NSItemProvider(object: jsonString as NSString)
        return [UIDragItem(itemProvider: itemProvider)]
    }
}

extension SharedVideoEditViewController: UICollectionViewDropDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        canHandle session: any UIDropSession
    ) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: any UICollectionViewDropCoordinator
    ) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        var snapshot = videoTimelineDataSource.snapshot()
        
        let draggedItems: [VideoTimelineItem] = coordinator.items.compactMap { item in
            if let sourceIndexPath = item.sourceIndexPath {
                return snapshot.itemIdentifiers[sourceIndexPath.item]
            }
            return nil
        }

        snapshot.deleteItems(draggedItems)
        let targetIndex = destinationIndexPath.item
        let currentItems = snapshot.itemIdentifiers
        var updatedItems = currentItems
        updatedItems.insert(contentsOf: draggedItems, at: targetIndex)
        
        applySnapShot(with: updatedItems)

        coordinator.items.forEach { item in
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
}
