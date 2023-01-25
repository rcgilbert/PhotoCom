//
//  PhotoDetailsViewControllerTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
@testable import PhotoCom

final class PhotoDetailsViewControllerTests: XCTestCase {
    var mockViewModel: MockPhotoDetailsViewModel!
    var mockPhotos: Photos!
    var subject: PhotoDetailsViewController!
    
    override func setUpWithError() throws {
        mockPhotos = MockData.photos?.filter { $0.albumID == 1 }
        mockViewModel = MockPhotoDetailsViewModel()
        mockViewModel.photos = mockPhotos
        subject = PhotoDetailsViewController(viewModel: mockViewModel)
    }
    
    func test_title() {
        subject.loadViewIfNeeded()
        
        XCTAssertEqual(subject.title, mockViewModel.title.value)
        mockViewModel.title.send("New Title")
        XCTAssertEqual(subject.title, mockViewModel.title.value)
    }
    
    func test_numberOfSections_ShouldBeOne() {
        subject.loadViewIfNeeded()
        XCTAssertEqual(subject.collectionView.numberOfSections, 1)
    }
    
    func test_numberOfRows() {
        subject.loadViewIfNeeded()
        XCTAssertEqual(subject.collectionView.numberOfItems(inSection: 0), mockPhotos.count)
    }
    
    func test_collectionViewLayoutSet() {
        subject.loadViewIfNeeded()
        XCTAssertEqual(subject.collectionView.collectionViewLayout, mockViewModel.collectionViewLayout)
    }
    
    func test_prefectDataCalled() {
        subject.loadViewIfNeeded()
        subject.collectionView(subject.collectionView, prefetchItemsAt: [IndexPath(item: 0, section: 0)])
        XCTAssertTrue(mockViewModel.prefetchImageCalled)
    }
    
    func test_cellIsConfiguredAtIndexPath() {
        subject.loadViewIfNeeded()
        subject.collectionView.layoutIfNeeded()
        
        XCTAssertFalse(subject.collectionView.indexPathsForVisibleItems.isEmpty)
        // Check visible cells have been configured
        for indexPath in subject.collectionView.indexPathsForVisibleItems {
            XCTAssertTrue(mockViewModel.configuredCellsAtIndexPaths.contains(indexPath))
        }
    }
    
    func test_collectionViewScrollsToInitialIndexPath() {
        mockViewModel.initialIndexPath = .init(item: mockPhotos.count - 1, section: 0)
        subject.loadViewIfNeeded()
        
        // Check to see if `initialIndexPath` was configured instead of adding hacky logic to wait for the `collectionView` `contentOffset` to update.
        XCTAssertTrue(mockViewModel.configuredCellsAtIndexPaths.contains(IndexPath(item: mockPhotos.count - 1, section: 0)))
    }
}
