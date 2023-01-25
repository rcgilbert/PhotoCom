//
//  MockPhotosViewModel.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import UIKit
import Combine
@testable import PhotoCom

class MockPhotosViewModel: PhotosViewModelType {
    var title: String = "Mock Photos"
    
    var state: CurrentValueSubject<PhotoCom.PhotosState, Never> = .init(.success)
    
    var selectedIndexPath: IndexPath = .init(item: 0, section: 0)
    
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    var configuredCellsAtIndexPaths: [IndexPath] = []
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        configuredCellsAtIndexPaths.append(indexPath)
    }
}
