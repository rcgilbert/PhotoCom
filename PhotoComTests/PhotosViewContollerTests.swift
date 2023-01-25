//
//  PhotosViewContollerTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
@testable import PhotoCom

final class PhotosViewContollerTests: XCTestCase {

    var subject: PhotosViewController!
    var mockViewModel: MockPhotosViewModel!
    
    override func setUpWithError() throws {
        mockViewModel = MockPhotosViewModel()
        subject = PhotosViewController(viewModel: mockViewModel)
        subject.loadViewIfNeeded()
    }

    func test_title() {
        XCTAssertEqual(subject.title, mockViewModel.title)
    }
    
    func test_numberOfSections_ShouldBeOne() {
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
    }
    
    func test_numberOfRows_Initial() {
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 0)
    }
    
    func test_numberOfRows_AfterLoading() {
        guard let mockPhotos = MockData.photos?.filter({$0.albumID == 1}) else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), 0)
        
        mockViewModel.state.send(.loading)
        mockViewModel.photos = mockPhotos
        mockViewModel.state.send(.success)
        subject.collectionView.layoutIfNeeded() // Ensure reload data is completed
       
        XCTAssertGreaterThan(subject.collectionView.numberOfItems(inSection: 0), 0)
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), mockPhotos.count)
    }
    
    func test_loadDataCalled() {
        XCTAssert(mockViewModel.loadDataCalled)
    }
    
    func test_collectionViewLayoutSet() {
        XCTAssertEqual(subject.collectionView.collectionViewLayout, mockViewModel.collectionViewLayout)
    }
    
    func test_prefectDataCalled() {
        subject.collectionView(subject.collectionView, prefetchItemsAt: [IndexPath(item: 0, section: 0)])
        XCTAssertTrue(mockViewModel.prefetchImageCalled)
    }
    
    func test_cellIsConfiguredAtIndexPath_One() {
        XCTAssertTrue(mockViewModel.configuredCellsAtIndexPaths.isEmpty)
        
        // Load the mock data into the table view
        mockViewModel.state.send(.loading)
        mockViewModel.photos = [Photo(albumID: 100,
                                      id: 1,
                                      title: "Mock Photo",
                                      url: "https://example.com/mockPhoto.jpg",
                                      thumbnailURL: "https://example.com/mockThumbnail.jpg")]
        mockViewModel.state.send(.success)
        subject.collectionView.layoutIfNeeded() // Ensure reload data is completed
        
        XCTAssertEqual(mockViewModel.configuredCellsAtIndexPaths, [IndexPath(item: 0, section: 0)])
    }
    
    func test_cellIsConfiguredAtIndexPath_Many() {
        XCTAssertTrue(mockViewModel.configuredCellsAtIndexPaths.isEmpty)
        guard let mockPhotos = MockData.photos else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        // Load the mock data into the table view
        mockViewModel.state.send(.loading)
        mockViewModel.photos = mockPhotos
        mockViewModel.state.send(.success)
        subject.collectionView.layoutIfNeeded() // Ensure reload data is completed
        
        XCTAssertFalse(subject.collectionView.indexPathsForVisibleItems.isEmpty)
        // Check visible cells have been configured
        for indexPath in subject.collectionView.indexPathsForVisibleItems {
            XCTAssertTrue(mockViewModel.configuredCellsAtIndexPaths.contains(indexPath))
        }
    }
}
