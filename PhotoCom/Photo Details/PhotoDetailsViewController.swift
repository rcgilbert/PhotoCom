//
//  PhotoDetailsViewController.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit
import Combine

/// Displays a photo full screen with pinch-to-zoom functionality.
/// Other photos in the album can be accessed by paging horizontally.
final class PhotoDetailsViewController: UIViewController {
    
    let viewModel: PhotoDetailsViewModelType
    
    let transitionController: ZoomTransitionController = .init()
    
    private(set) lazy var collectionView: UICollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.prefetchDataSource = self
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: viewModel.collectionViewLayout))
    
    private lazy var tapGestureRecogizer: UITapGestureRecognizer = {
        $0.addTarget(self, action: #selector(toggleNavigationBar))
        return $0
    }(UITapGestureRecognizer())
    
    private var cancellables: Set<AnyCancellable> = .init()

    init(viewModel: PhotoDetailsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        setUpView()
        
        view.layoutIfNeeded()
        collectionView
            .scrollToItem(at: self.viewModel.initialIndexPath, at: .centeredHorizontally, animated: false)
        
        viewModel.title.sink { title in
            self.title = title
        }.store(in: &cancellables)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Prevent random scrolling offset changes when rotating the device
        let indexPath = self.viewModel.selectedIndexPath.value
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(PhotoDetailsCollectionViewCell.self, forCellWithReuseIdentifier: PhotoDetailsCollectionViewCell.defaultReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
    
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        collectionView.addGestureRecognizer(tapGestureRecogizer)
        collectionView.layoutIfNeeded()
    }
    
    @objc private func toggleNavigationBar() {
        navigationController?
            .setNavigationBarHidden(navigationController?.navigationBar.isHidden == false, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoDetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoDetailsCollectionViewCell.defaultReuseIdentifier, for: indexPath)
        viewModel.configure(cell: cell, for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotoDetailsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            viewModel.prefetchImage(for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoDetailsViewController:  UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotoDetailsCollectionViewCell {
            cell.scrollView.zoomScale = 1.0
        }
    }
}


// MARK: - ZoomAnimatorDelegate

extension PhotoDetailsViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        // This is a workaround for a bug internal to `UICollectionView`.
        // Occasionally, when attempting to scroll to an index path in `viewDidLoad`
        // the collection view will scroll to the wrong index path (~ +2 cells).
        // This bug occurs most often when using an iPhone in landscape mode and tapping the bottom right cell on the screen.
        // This also occurs using both custom and default transitions.
        collectionView
            .scrollToItem(at: self.viewModel.initialIndexPath, at: .centeredHorizontally, animated: false)
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        let cell = collectionView.cellForItem(at: viewModel.selectedIndexPath.value) as? PhotoDetailsCollectionViewCell
        return cell?.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        guard let cell = collectionView.cellForItem(at: viewModel.selectedIndexPath.value) as? PhotoDetailsCollectionViewCell else {
            return nil
        }
        
        let unconvertedFrame = cell.imageView.frame
        let cellFrame = collectionView.convert(unconvertedFrame, to: self.view)
        
        return cellFrame
    }
}
