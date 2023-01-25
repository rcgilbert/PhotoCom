//
//  PhotoDetailsViewModelTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
@testable import PhotoCom

final class PhotoDetailsViewModelTests: XCTestCase {
    var mockImageService: MockImageService!
    var subject: PhotoDetailsViewModel!
    var mockPhotos: Photos!
    
    override func setUpWithError() throws {
        mockPhotos = MockData.photos?.filter { $0.albumID == 1 }
        mockImageService = MockImageService()
        subject = PhotoDetailsViewModel(photos: mockPhotos,
                                        initialIndexPath: .init(item: 0, section: 0),
                                        imageService: mockImageService)
    }
    
    func test_title() {
        subject.didScrollToPage(0)
        XCTAssertEqual(subject.title.value, mockPhotos[0].title)
        subject.didScrollToPage(mockPhotos.count - 1)
        XCTAssertEqual(subject.title.value, mockPhotos[mockPhotos.count - 1].title)
    }
    
    func test_selectedIndexPath() {
        subject.didScrollToPage(0)
        XCTAssertEqual(subject.selectedIndexPath.value, IndexPath(item: 0, section: 0))
        subject.didScrollToPage(mockPhotos.count - 1)
        XCTAssertEqual(subject.selectedIndexPath.value, IndexPath(item: mockPhotos.count - 1, section: 0))
    }
    
    func test_numberOfRows() {
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
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, "https://example.com/image.jpg")
    }
    
    func test_configureCell() {
        let mockImage = UIImage()
        mockImageService.mockImage = mockImage
        
        let testCell = PhotoDetailsCollectionViewCell()
        subject.configure(cell: testCell, for: IndexPath(item: 0, section: 0))
        
        waitFor { self.mockImageService.loadImageURL != nil }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, mockPhotos.first?.url)
        XCTAssertEqual(testCell.imageView.image, mockImage)
    }
    
    func test_configureCell_Reuse() {
        let mockImage = UIImage()
        mockImageService.mockImage = mockImage

        let testCell = PhotoDetailsCollectionViewCell()
        subject.configure(cell: testCell, for: IndexPath(item: 0, section: 0))
        subject.configure(cell: testCell, for: IndexPath(item: 1, section: 0))
        
        waitFor { self.mockImageService.loadImageURL != nil }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, mockPhotos[1].url)
        XCTAssertEqual(testCell.imageView.image, mockImage)
        XCTAssertFalse(testCell.showErrorState)
    }
    
    func test_configureCell_FailedToLoadImage() {
        mockImageService.mockImage = nil
        
        let testCell = PhotoDetailsCollectionViewCell()
        subject.configure(cell: testCell, for: IndexPath(item: 0, section: 0))
        
        waitFor { self.mockImageService.loadImageURL != nil }
        
        XCTAssertNotNil(mockImageService.loadImageURL)
        XCTAssertEqual(mockImageService.loadImageURL?.absoluteString, mockPhotos.first?.url)
        XCTAssertNil(testCell.imageView.image)
        XCTAssertTrue(testCell.showErrorState)
    }
}
