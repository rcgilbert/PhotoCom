//
//  AlbumViewControllerTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
@testable import PhotoCom

final class AlbumViewControllerTests: XCTestCase {
    
    var subject: AlbumsViewController!
    var mockViewModel: MockAlbumsViewModel!
    
    override func setUpWithError() throws {
        mockViewModel = MockAlbumsViewModel()
        
        subject = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "AlbumsViewController") { coder in
            return AlbumsViewController(coder: coder, viewModel: self.mockViewModel)
        }
        
        subject.loadViewIfNeeded()
    }
    
    func test_numberOfSections_ShouldBeOne() {
        XCTAssertEqual(subject.tableView.numberOfSections, 1)
    }
    
    func test_numberOfRows_Initial() {
        XCTAssertEqual(subject.tableView.numberOfRows(inSection: 0), 0)
    }
    
    func test_numberOfRows_AfterLoading() {
        guard let mockAlbums = MockData.albums else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        XCTAssertEqual(subject.tableView.numberOfRows(inSection: 0), 0)
        
        // Simulate API Fetch
        mockViewModel.mockState.send(.loading)
        mockViewModel.mockAlbums = mockAlbums
        mockViewModel.mockState.send(.success)
        subject.tableView.layoutIfNeeded() // Ensure reload data is completed
        
        XCTAssertGreaterThan(subject.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(subject.tableView.numberOfRows(inSection: 0), mockAlbums.count)
    }
    
    func test_loadDataCalled() {
        XCTAssert(mockViewModel.loadDataCalled)
    }
    
    func test_cellIsConfiguredAtIndexPath_One() {
        XCTAssertNil(mockViewModel.configuredCellAtIndexPath)
        
        // Load the mock data into the table view
        mockViewModel.mockState.send(.loading)
        mockViewModel.mockAlbums = [Album(userID: 100, id: 1, title: "Test Album")]
        mockViewModel.mockState.send(.success)
        subject.tableView.layoutIfNeeded() // Ensure reload data is completed
        
        XCTAssertEqual(mockViewModel.configuredCellAtIndexPath, IndexPath(item: 0, section: 0))
    }
    
    func test_cellIsConfiguredAtIndexPath_Many() {
        XCTAssertNil(mockViewModel.configuredCellAtIndexPath)
        guard let mockAlbums = MockData.albums else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        // Load the mock data into the table view
        mockViewModel.mockState.send(.loading)
        mockViewModel.mockAlbums = mockAlbums
        mockViewModel.mockState.send(.success)
        subject.tableView.layoutIfNeeded() // Ensure reload data is completed
        
        // Get last visible index path to check if it was configured
        let lastVisibleIndexPath = subject.tableView.indexPathsForVisibleRows!.last!
        
        XCTAssertEqual(mockViewModel.configuredCellAtIndexPath, lastVisibleIndexPath)
    }
}
