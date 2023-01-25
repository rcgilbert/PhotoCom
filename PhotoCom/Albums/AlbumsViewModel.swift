//
//  AlbumsViewModel.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit
import Combine

protocol AlbumsViewModelType {
    // State
    var state: AnyPublisher<AlbumsState, Never> { get }
    
    // Data
    func loadData()
    func album(for indexPath: IndexPath) -> Album
    
    // Table View
    var numberOfRows: Int { get }
    func configure(cell: UITableViewCell, for indexPath: IndexPath)
}

enum AlbumsState {
    case loading
    case success
    case failure(_ error: Error)
}

/// The view model for `AlbumsViewController`
final class AlbumsViewModel: AlbumsViewModelType {
    private let dataService: DataServiceType
    
    private var albums: Albums = []
    private var usersForId: [Int: User] = [:]
     
    var state: AnyPublisher<AlbumsState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    private let stateSubject: PassthroughSubject<AlbumsState, Never> = PassthroughSubject()
    
    var numberOfRows: Int {
        albums.count
    }
    
    init(dataService: DataServiceType = DataService()) {
        self.dataService = dataService
    }
    
    func loadData() {
        stateSubject.send(.loading)
        Task { [dataService] in
            let result  = await dataService.getAlbumsAndUsers()
            switch result {
            case .success((let albums, let users)):
                self.albums = albums
                
                self.usersForId = [:]
                for user in users {
                    usersForId[user.id] = user
                }
                
                stateSubject.send(.success)
                break
            case .failure(let error):
                stateSubject.send(.failure(error))
            }
        }
    }
    
    func album(for indexPath: IndexPath) -> Album {
        return albums[indexPath.row]
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell  = cell as? AlbumTableViewCell else {
            return
        }
        let album = albums[indexPath.row]
        let user = usersForId[album.userID]
        
        cell.titleLabel.text = album.title
        cell.ownerLabel.text = user?.name
    }
}
