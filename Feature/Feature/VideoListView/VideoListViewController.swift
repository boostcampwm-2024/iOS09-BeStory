//
//  VideoListViewController.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import Combine
import Core
import PhotosUI
import UIKit

public final class VideoListViewController: UIViewController {
    private let viewModel: any VideoListViewModel
    private let input = PassthroughSubject<VideoListViewInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let fileSystemManager = FileSystemManager.shared
    
    // MARK: - UI Components
    private let headerView = VideoListHeaderView()
    private var collectionView: UICollectionView!
    private let nextButton = UIButton()
  
    private var dataSource: VideoListDataSource!
    private let spacing: CGFloat = 20
    
    private var items: [VideoListItem] = [] {
        didSet {
            reload(with: items)
        }
    }
    
    // MARK: - Initializers
    public init(viewModel: any VideoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
        setupViewBinding()
        setupNextButton()
        
        input.send(.viewDidLoad)
    }
}

// MARK: - Setting
private extension VideoListViewController {
    func setupViewAttributes() {
        view.backgroundColor = .black
        collectionView.register(VideoListCollectionViewCell.self,
                                forCellWithReuseIdentifier: VideoListCollectionViewCell.identifier)
        collectionView.delegate = self
    }
    
    func setupViewHierarchies() {
        view.addSubview(headerView)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
    }
    
    func setupViewConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    func setupViewBinding() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .videoListDidChanged(let videos):
                    self?.items = videos
                case .readyForNextScreen:
                    self?.navigateToEditor()
                }
            }
            .store(in: &cancellables)
        
        headerView.addVideoButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.openVideoPicker()
            }
            .store(in: &cancellables)
        
        nextButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.input.send(.validateSynchronization)
            }
            .store(in: &cancellables)
    }
    
    func setupNextButton() {
        nextButton.backgroundColor = .white
        nextButton.layer.cornerRadius = 25
        nextButton.setTitle("편집하기", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
    }
    
    func setupCollectionView() {
        let layout = makeLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        
        let dataSource = makeDataSource()
        self.dataSource = dataSource
        collectionView.dataSource = dataSource
        
        applySnapshot(with: [])
    }
    
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        return layout
    }
    
    func makeDataSource() -> VideoListDataSource {
        let dataSource = VideoListDataSource(collectionView: collectionView,
                                             cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VideoListCollectionViewCell.identifier,
                for: indexPath
            )
            guard let cell = cell as? VideoListCollectionViewCell
            else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        })
        return dataSource
    }
    
    func applySnapshot(with items: [VideoListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<VideoListSection, VideoListItem>()
        snapshot.appendSections([.list])
        snapshot.appendItems(items, toSection: .list)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reload(with videos: [VideoListItem]) {
        applySnapshot(with: videos)
        headerView.configure(with: videos.count)
    }
    
    func openVideoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func navigateToEditor() {
        let tempViewController = TempViewController(nibName: nil, bundle: nil)
        navigationController?.pushViewController(tempViewController, animated: true)
    }
}

// MARK: - Collection View
extension VideoListViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedVideo = items[indexPath.row]
        present(VideoDetailViewController(video: selectedVideo), animated: true)
    }
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cell = VideoListCollectionViewCell()
        
        cell.configure(with: items[indexPath.row])
        
        let width = (collectionView.bounds.width - (spacing + 0.1)) / 2
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return cell.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - PHPicker
extension VideoListViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) else { return }
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] tempURL, error in
            guard let tempURL, error == nil,
                  let url = self?.fileSystemManager.copyToFileSystem(tempURL: tempURL) else { return }
            self?.input.send(.appendVideo(url: url))
        }
    }
}
