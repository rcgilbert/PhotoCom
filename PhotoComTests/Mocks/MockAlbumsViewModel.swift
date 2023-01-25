//
//  MockAlbumsViewModel.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import UIKit
import Combine
@testable import PhotoCom

class MockAlbumsViewModel: AlbumsViewModelType {
    var mockAlbums: Albums = []
    
    var mockState: CurrentValueSubject<PhotoCom.AlbumsState, Never> = .init(.success)
    var state: AnyPublisher<PhotoCom.AlbumsState, Never> {
        mockState.eraseToAnyPublisher()
    }
    
    var loadDataCalled = false
    func loadData() {
        loadDataCalled = true
    }
    
    func album(for indexPath: IndexPath) -> PhotoCom.Album {
        mockAlbums[indexPath.row]
    }
    
    var numberOfRows: Int {
        mockAlbums.count
    }
    
    var configuredCellAtIndexPath: IndexPath?
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        configuredCellAtIndexPath = indexPath
    }
}
