//
//  PhotosViewModelTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
import Combine
@testable import PhotoCom

final class PhotosViewModelTests: XCTestCase {
    
    var mockDataService: MockDataService!
    var mockImageService: MockImageService!
    var subject: PhotosViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockAlbum: Album!
    
    override func setUpWithError() throws {
        mockDataService = MockDataService()
        mockImageService = MockImageService()
        mockAlbum = Album(userID: 1, id: 1, title: "Mock Album")
        subject = PhotosViewModel(album: mockAlbum, imageService: mockImageService, dataService: mockDataService)
        cancellables = .init()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
    }

    func test_title() {
        XCTAssertEqual(subject.title, mockAlbum.title)
    }
    
    func test_loadData_Success() {
        guard let mockPhotos = MockData.photos else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        mockDataService.mockPhotosResult = .success(mockPhotos)
        
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
        
        XCTAssertTrue(mockDataService.getPhotosCalled)
        XCTAssertTrue(success)
        XCTAssertFalse(failure)
        XCTAssertTrue(didLoad)
    }
    
    func test_loadData_Failure() {
        mockDataService.mockPhotosResult = .failure(MockError.mockError)

        var failure = false
        var didLoad = false
        subject.state.sink { state in
            switch state {
            case .success:
                break
            case .failure:
                failure = true
            case .loading:
                didLoad = true
            }
        }.store(in: &cancellables)
        
        // Call Load Data
        subject.loadData()
        
        waitForMockDataToLoad()
        
        XCTAssertTrue(mockDataService.getPhotosCalled)
        XCTAssertTrue(failure)
        XCTAssertTrue(didLoad)
        
    }
    
    func test_numberOfRows() {
        // Load Mock Data
        guard let mockPhotos = MockData.photos?.filter({ $0.albumID == mockAlbum.id }) else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        subject.photos = mockPhotos
        
        XCTAssertGreaterThan(subject.numberOfItems, 0)
        XCTAssertEqual(subject.numberOfItems, mockPhotos.count)
    }
    
    func test_prefetchImage() {
        subject.photos = [Photo(albumID: 1,
                                id: 1,
                                title: "Mock Photo",
                                url: "https://example.com/image.jpg",
                                thumbnailURL: "https://example.com/thumbnail.jpg")]
        
        subject.prefetchImage(for: IndexPath(item: 0, section: 0))
        
        waitFor {
            self.mockImageService.loadImageURL != nil
        }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, "https://example.com/thumbnail.jpg")
    }
    
    func test_configureCell() {
        guard let mockPhotos = MockData.photos?.filter({ $0.albumID == mockAlbum.id }) else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        let mockImage = UIImage()
        mockImageService.mockImage = mockImage
        
        subject.photos = mockPhotos
        
        let testCell = PhotoCollectionViewCell()
        subject.configure(cell: testCell, for: IndexPath(item: 0, section: 0))
        
        waitFor { self.mockImageService.loadImageURL != nil }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, mockPhotos.first?.thumbnailURL)
        XCTAssertEqual(testCell.imageView.image, mockImage)
        XCTAssertFalse(testCell.showErrorState)
    }
    
    func test_configureCell_Reuse() {
        guard let mockPhotos = MockData.photos?.filter({ $0.albumID == mockAlbum.id }) else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        let mockImage = UIImage()
        mockImageService.mockImage = mockImage
        
        subject.photos = mockPhotos
        
        let testCell = PhotoCollectionViewCell()
        subject.configure(cell: testCell, for: IndexPath(item: 0, section: 0))
        subject.configure(cell: testCell, for: IndexPath(item: 1, section: 0))
        
        waitFor { self.mockImageService.loadImageURL != nil }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, mockPhotos[1].thumbnailURL)
        XCTAssertEqual(testCell.imageView.image, mockImage)
        XCTAssertFalse(testCell.showErrorState)
    }
    
    func test_configureCell_FailedToLoadImage() {
        guard let mockPhotos = MockData.photos?.filter({ $0.albumID == mockAlbum.id }) else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        mockImageService.mockImage = nil
        
        subject.photos = mockPhotos
        
        let testCell = PhotoCollectionViewCell()
        subject.configure(cell: testCell, for: IndexPath(item: 0, section: 0))
        
        waitFor { self.mockImageService.loadImageURL != nil }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, mockPhotos.first?.thumbnailURL)
        XCTAssertNil(testCell.imageView.image)
        XCTAssertTrue(testCell.showErrorState)
    }
    
    
    // MARK: - Helpers
    
    private func waitForMockDataToLoad() {
        waitFor {
            self.mockDataService.getPhotosCalled == true
        }
    }
}
