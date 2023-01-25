//
//  PhotoDetailsViewModel.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit
import Combine
protocol PhotoDetailsViewModelType: AnyObject {
    var title: CurrentValueSubject<String, Never> { get }
    var photos: Photos { get }
    var initialIndexPath: IndexPath { get }
    var selectedIndexPath: CurrentValueSubject<IndexPath, Never> { get }
    
    //Data
    func prefetchImage(for indexPath: IndexPath)
    
    // Collection view
    var numberOfItems: Int { get }
    var collectionViewLayout: UICollectionViewLayout { get }
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath)
}

/// The view model for `PhotoDetailsViewController`.
final class PhotoDetailsViewModel: PhotoDetailsViewModelType {
    private let imageService: ImageServiceType
    
    var title: CurrentValueSubject<String, Never> = .init("")
    var photos: Photos
    var initialIndexPath: IndexPath
    var selectedIndexPath: CurrentValueSubject<IndexPath, Never> = .init(IndexPath(item: 0, section: 0))
    
    init(photos: Photos, initialIndexPath: IndexPath,
         imageService: ImageServiceType = ImageService.shared) {
        self.photos = photos
        self.imageService = imageService
        self.initialIndexPath = initialIndexPath
    }
    
    var numberOfItems: Int {
        photos.count
    }
    
    var collectionViewLayout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, contentOffset, environment in
            let pageOffset =  Int(max(0 , round(contentOffset.x / environment.container.contentSize.width)))
            self?.didScrollToPage(pageOffset)
        }
        section.orthogonalScrollingBehavior = .groupPaging
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func prefetchImage(for indexPath: IndexPath) {
        if let imageURL = URL(string: photos[indexPath.item].url) {
            Task { [imageService] in
                await imageService.loadImage(imageURL)
            }
        }
    }
    
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? PhotoDetailsCollectionViewCell else {
            return
        }
        
        // Reset cell to Loading State while photo is loaded
        cell.imageView.image = nil
       
        let photo = photos[indexPath.item]
        cell.photoID = photo.id
        
        // Attempt to load and set image from URL
        if let imageURL = URL(string: photos[indexPath.item].url) {
            Task { [imageService] in
                let image = await imageService.loadImage(imageURL)
                
                await MainActor.run {
                    guard photo.id == cell.photoID else {
                        print("Cell was reused before image loaded!")
                        return
                    }
                    
                    if let image = image {
                        cell.imageView.contentMode = .scaleAspectFit
                        cell.imageView.image = image
                    } else {
                        cell.showErrorState = true
                    }
                }
            }
        } else {
            cell.showErrorState = true
        }
    }
    
    // MARK: - Scrolling State
    
    func didScrollToPage(_ page: Int) {
        selectedIndexPath.send(IndexPath(item: page, section: 0))
        title.send(photos[page].title)
    }
}
