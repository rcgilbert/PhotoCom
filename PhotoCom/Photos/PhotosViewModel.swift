//
//  PhotosViewModel.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit
import Combine

protocol PhotosViewModelType: AnyObject {
    var title: String { get }
    
    // State
    var state: CurrentValueSubject<PhotosState, Never> { get }
    var selectedIndexPath: IndexPath { get set }
    
    // Data
    var photos: Photos { get }
    func loadData()
    func prefetchImage(for indexPath: IndexPath)
    
    // Collection view
    var numberOfItems: Int { get }
    var collectionViewLayout: UICollectionViewLayout { get }
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath)
    
}

enum PhotosState {
    case loading
    case success
    case failure(_ error: Error)
}

/// The view model for `PhotosViewController`.
final class PhotosViewModel: PhotosViewModelType {
    
    private let imageService: ImageServiceType
    private let dataService: DataServiceType
    
    private let album: Album
    var photos: Photos = []
    
    var title: String {
        album.title
    }
    
    var state: CurrentValueSubject<PhotosState, Never> = .init(.success)
    
    var selectedIndexPath: IndexPath = .init(item: 0, section: 0)
    
    var numberOfItems: Int {
        photos.count
    }
    
    var collectionViewLayout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    init(album: Album, imageService: ImageServiceType = ImageService.shared, dataService: DataServiceType = DataService()) {
        self.album = album
        self.imageService = imageService
        self.dataService = dataService
    }
    
    func loadData() {
        state.send(.loading)
        Task { [weak self, dataService] in
            guard let self = self else {
                return
            }
            
            let result = await dataService.getPhotos()
            switch result {
            case .success(let photos):
                self.photos = photos.filter { $0.albumID == self.album.id }
                self.state.send(.success)
            case .failure(let error):
                self.state.send(.failure(error))
            }
        }
    }
    
    func prefetchImage(for indexPath: IndexPath) {
        if let imageURL = URL(string: photos[indexPath.row].thumbnailURL) {
            Task { [imageService] in
                await imageService.loadImage(imageURL)
            }
        }
    }
    
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? PhotoCollectionViewCell else {
            return
        }
        
        // Reset cell to Loading State while photo is loaded
        cell.imageView.image = nil
        
        let photo = photos[indexPath.row]
        cell.photoID = photo.id
        
        // Attempt to load and set image from URL
        if let imageURL =  URL(string: photos[indexPath.item].thumbnailURL) {
            Task { [imageService] in
                let thumbnail = await imageService.loadImage(imageURL)
                
                await MainActor.run {
                    guard photo.id == cell.photoID else {
                        print("Cell was reused before image loaded!")
                        return
                    }
                    
                    if let thumbnail = thumbnail {
                        cell.imageView.contentMode = .scaleAspectFill
                        cell.imageView.image = thumbnail
                    } else {
                        cell.showErrorState = true
                    }
                }
            }
        } else {
            cell.showErrorState = true
        }
    }
}
