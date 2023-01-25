//
//  AlbumViewModelTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
import Combine
@testable import PhotoCom

final class AlbumViewModelTests: XCTestCase {
    
    var subject: AlbumsViewModel!
    var mockDataService: MockDataService!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        mockDataService = MockDataService()
        subject = AlbumsViewModel(dataService: mockDataService)
        cancellables = .init()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
    }
    
    func test_loadData_Success() {
        guard let mockAlbums = MockData.albums,
        let mockUsers = MockData.users else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        
        mockDataService.mockAlbumsAnyUsersResult = .success((mockAlbums, mockUsers))
        
        var success = false
        var failure = false
        var didLoad = false
        subject.state.sink { state in
            switch state {
            case .success:
                success = true
            case .failure:
                failure = true
            case .loading:
                didLoad = true
            }
        }.store(in: &cancellables)
        
        // Call Load Data
        subject.loadData()
        
        waitForMockDataToLoad()
        
        XCTAssertTrue(mockDataService.getAlbumsAndUsersCalled)
        XCTAssertTrue(success)
        XCTAssertFalse(failure)
        XCTAssertTrue(didLoad)
    }
    
    func test_loadData_Failure() {
        mockDataService.mockAlbumsAnyUsersResult = .failure(MockError.mockError)
        
        var success = false
        var failure = false
        var didLoad = false
        subject.state.sink { state in
            switch state {
            case .success:
                success = true
            case .failure:
                failure = true
            case .loading:
                didLoad = true
            }
        }.store(in: &cancellables)
        
        // Call Load Data
        subject.loadData()
        
        waitForMockDataToLoad()
        
        XCTAssertTrue(mockDataService.getAlbumsAndUsersCalled)
        XCTAssertFalse(success)
        XCTAssertTrue(failure)
        XCTAssertTrue(didLoad)
    }
    
    func test_albumForIndexPath() {
        guard let mockAlbums = MockData.albums,
        let mockUsers = MockData.users else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        
        mockDataService.mockAlbumsAnyUsersResult = .success((mockAlbums, mockUsers))
        subject.loadData()
        waitForMockDataToLoad()
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        let middleIndexPath = IndexPath(row: mockAlbums.count / 2, section: 0)
        let lastIndexPath = IndexPath(row: mockAlbums.count - 1, section: 0)
        
        XCTAssertEqual(subject.album(for: firstIndexPath), mockAlbums[firstIndexPath.row])
        XCTAssertEqual(subject.album(for: middleIndexPath), mockAlbums[middleIndexPath.row])
        XCTAssertEqual(subject.album(for: lastIndexPath), mockAlbums[lastIndexPath.row])
    }
    
    func test_numberOfRows() {
        // Load in Mock Data
        guard let mockAlbums = MockData.albums,
        let mockUsers = MockData.users else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        mockDataService.mockAlbumsAnyUsersResult = .success((mockAlbums, mockUsers))
        subject.loadData()
        
        waitForMockDataToLoad()
        
        XCTAssertGreaterThan(subject.numberOfRows, 0)
        XCTAssertEqual(subject.numberOfRows, mockAlbums.count)
    }
    
    func test_configureCell() {
        let mockAlbum = Album(userID: 100, id: 1, title: "Mock Album")
        let mockUser = User(id: 100,
                            name: "Mock User",
                            username: "mUser",
                            email: "mUser@example.com",
                            address: Address(street: "123 Fake St.",
                                             suite: "",
                                             city: "Springfield",
                                             zipcode: "555555",
                                             geo: Geo(lat: "-1", lng: "-1")),
                            phone: "+15555555555",
                            website: "https://example.com",
                            company: Company(name: "Mock Company",
                                             catchPhrase: "We're the realest",
                                             bs: ""))
        mockDataService.mockAlbumsAnyUsersResult = .success(([mockAlbum], [mockUser]))
        subject.loadData()
        waitForMockDataToLoad()
        
        
        let testCell = AlbumTableViewCell()
        subject.configure(cell: testCell, for: IndexPath(row: 0, section: 0))
        XCTAssertEqual(testCell.titleLabel.text, "Mock Album")
        XCTAssertEqual(testCell.ownerLabel.text, "Mock User")
    }
    
    private func waitForMockDataToLoad() {
        // Wait for Call to Complete
        waitFor {
            self.mockDataService.getAlbumsAndUsersCalled == true
        }
    }
}
