//
//  PhotosViewController.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit
import Combine

/// Displays a grid of images that below to a particular gallery.
final class PhotosViewController: UIViewController {
    
    private let viewModel: PhotosViewModelType
    
    private(set) lazy var collectionView: UICollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.prefetchDataSource = self
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: viewModel.collectionViewLayout))
    
    private lazy var refreshControl: UIRefreshControl = {
        $0.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return $0
    }(UIRefreshControl())
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(viewModel: PhotosViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        
        title = viewModel.title
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    self?.collectionView.reloadData()
                    self?.refreshControl.endRefreshing()
                case .failure(_):
                    self?.refreshControl.endRefreshing()
                }
            }.store(in: &cancellables)
        
        setUp()
        
        viewModel.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove delegate to prevent custom animation between Photos and Albums screens.
        navigationController?.delegate = nil
    }
    
    // MARK: - Set Up
    
    private func setUp() {
        view.backgroundColor = .systemBackground
        
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.defaultReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    
    // MARK: - Helpers
    
    private func getCollectionViewCell(for selectedIndexPath: IndexPath) -> UICollectionViewCell {
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        if !visibleCells.contains(selectedIndexPath) {
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                return UICollectionViewCell(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            
            return guardedCell
        }
        else {
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                return UICollectionViewCell(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
        
            
            return guardedCell
        }
    }
    
    private func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        return getCollectionViewCell(for: selectedIndexPath).frame
    }
    
    @objc private func refreshData() {
        viewModel.loadData()
    }
}

// MARK: - UICollectionViewDataSource

extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.defaultReuseIdentifier, for: indexPath)
        viewModel.configure(cell: cell, for: indexPath)
        return cell
    }
}

extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            viewModel.prefetchImage(for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .success = viewModel.state.value else {
            return
        }
        
        viewModel.selectedIndexPath = indexPath
        
        let photoDetailsViewModel = PhotoDetailsViewModel(photos: viewModel.photos, initialIndexPath: indexPath)
        let photoDetailsVC = PhotoDetailsViewController(viewModel: photoDetailsViewModel)
        
        navigationController?.delegate = photoDetailsVC.transitionController
        photoDetailsVC.transitionController.fromDelegate = self
        photoDetailsVC.transitionController.toDelegate = photoDetailsVC
        
        show(photoDetailsVC, sender: nil)
        
        photoDetailsViewModel.selectedIndexPath.sink { [weak self] indexPath in
            self?.viewModel.selectedIndexPath = indexPath
        }.store(in: &cancellables)
    }
}

// MARK: - ZoomAnimatorDelegate

extension PhotosViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return (getCollectionViewCell(for: viewModel.selectedIndexPath) as? PhotoCollectionViewCell)?.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        let unconvertedFrame = getFrameFromCollectionViewCell(for: viewModel.selectedIndexPath)
        
        let cellFrame = self.collectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
}
