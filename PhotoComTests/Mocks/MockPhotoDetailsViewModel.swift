//
//  MockPhotoDetailsViewModel.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import UIKit
import Combine
@testable import PhotoCom

class MockPhotoDetailsViewModel: PhotoDetailsViewModelType {
    var title: CurrentValueSubject<String, Never> = .init("Mock Title")
    
    var initialIndexPath: IndexPath = .init(item: 0, section: 0)
    
    var selectedIndexPath: CurrentValueSubject<IndexPath, Never> = .init(.init(item: 0, section: 0))
    
    var photos: PhotoCom.Photos = []
    
    var loadDataCalled = false
    func loadData() {
        loadDataCalled = true
    }
    
    var prefetchImageCalled = false
    func prefetchImage(for indexPath: IndexPath) {
        prefetchImageCalled = true
    }
    
    var numberOfItems: Int {
        photos.count
    }
    
    var collectionViewLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    var configuredCellsAtIndexPaths: [IndexPath] = []
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        configuredCellsAtIndexPaths.append(indexPath)
    }
}
