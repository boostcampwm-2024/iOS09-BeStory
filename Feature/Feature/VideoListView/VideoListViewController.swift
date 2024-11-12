//
//  VideoListViewController.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import Combine
import UIKit

public final class VideoListViewController: UIViewController {
    private let viewModel: VideoListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let headerView = VideoListHeaderView()
    private var collectionView: UICollectionView!
    private var dataSource: VideoListDataSource!
    private let spacing: CGFloat = 20
    
    // MARK: - Initializers
    public init(viewModel: VideoListViewModel) {
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
        viewModel.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
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
    }
    
    func setupViewBinding() {
        viewModel.videos.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reload()
            }
            .store(in: &cancellables)
        
        headerView.addVideoButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.addVideo()
            }
            .store(in: &cancellables)
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
    
    func reload() {
        applySnapshot(with: viewModel.videos.value)
        headerView.configure(with: viewModel.videos.value.count)
    }
    
    func addVideo() {
        viewModel.appendVideo()
    }
}

// MARK: - Collection View

extension VideoListViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedVideo = viewModel.videos.value[indexPath.row]
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
        
        cell.configure(with: viewModel.videos.value[indexPath.row])
        
        let width = (collectionView.bounds.width - (spacing + 0.1)) / 2
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return cell.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}
