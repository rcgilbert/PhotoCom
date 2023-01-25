//
//  DataServiceTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
@testable import PhotoCom

final class DataServiceTests: XCTestCase {

    var subject: DataService!
    var mockURLSession: MockURLSession!
    
    override func setUpWithError() throws {
        mockURLSession = MockURLSession()
        subject = DataService(urlSession: mockURLSession)
    }

    func test_getAlbums() async {
        guard let mockData = MockData.albumsData,
            let mockAlbums = MockData.albums else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        mockURLSession.mockData = mockData
        let result = await subject.getAlbums()
        
        // Check Correct Request URL used
        XCTAssertNotNil(mockURLSession.urlRequest?.url?.absoluteString)
        XCTAssertEqual(mockURLSession.urlRequest!.url!.absoluteString, "https://jsonplaceholder.typicode.com/albums")
        
        // Check Correct Response
        switch result {
        case .success(let albums):
            XCTAssertEqual(albums, mockAlbums)
        case .failure(let error):
            XCTFail("Unexpected Error Occured: \(error)")
        }
    }
    
    func test_getUsers() async {
        guard let mockData = MockData.usersData,
            let mockUsers = MockData.users else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        mockURLSession.mockData = mockData
        let result = await subject.getUsers()
        
        // Check Correct Request URL used
        XCTAssertNotNil(mockURLSession.urlRequest?.url?.absoluteString)
        XCTAssertEqual(mockURLSession.urlRequest!.url!.absoluteString, "https://jsonplaceholder.typicode.com/users")
        
        // Check Correct Response
        switch result {
        case .success(let users):
            XCTAssertEqual(users, mockUsers)
        case .failure(let error):
            XCTFail("Unexpected Error Occured: \(error)")
        }
    }
    
    
    func test_getPhotos() async {
        guard let mockData = MockData.photosData,
            let mockPhotos = MockData.photos else {
            XCTFail("Invalid Mock Data")
            return
        }
        
        mockURLSession.mockData = mockData
        let result = await subject.getPhotos()
        
        // Check Correct Request URL used
        XCTAssertNotNil(mockURLSession.urlRequest?.url?.absoluteString)
        XCTAssertEqual(mockURLSession.urlRequest!.url!.absoluteString, "https://jsonplaceholder.typicode.com/photos")
        
        // Check Correct Response
        switch result {
        case .success(let photos):
            XCTAssertEqual(photos, mockPhotos)
        case .failure(let error):
            XCTFail("Unexpected Error Occured: \(error)")
        }
    }
    
    func test_getAlbumsAndUsers() async {
        // Due to mocking limitations we need to use an empty repsonse that can be mapped to both `Albums` and `Users`.
        mockURLSession.mockData = MockData.emptyRepsonse
        
        let result = await subject.getAlbumsAndUsers()
        
        switch result {
        case .success((let albums, let users)):
            XCTAssertEqual(albums, [])
            XCTAssertEqual(users, [])
        case .failure(let error):
            XCTFail("Unexpected Error Occured: \(error)")
        }
    }
    
    func test_getAlbums_NetworkClientFailure() async {
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        let result = await subject.getAlbums()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is NetworkClientError)
            if case NetworkClientError.networkError(let status) = error {
                XCTAssertEqual(status, 404)
            } else {
                XCTFail("Incorrect Error Returned")
            }
        }
    }
    
    func test_getUsers_NetworkClientFailure() async {
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        let result = await subject.getUsers()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is NetworkClientError)
            if case NetworkClientError.networkError(let status) = error {
                XCTAssertEqual(status, 404)
            } else {
                XCTFail("Incorrect Error Returned")
            }
        }
    }
    
    func test_getPhotos_NetworkClientFailure() async {
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        let result = await subject.getPhotos()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is NetworkClientError)
            if case NetworkClientError.networkError(let status) = error {
                XCTAssertEqual(status, 404)
            } else {
                XCTFail("Incorrect Error Returned")
            }
        }
    }
    
    func test_getAlbumsAndUsers_NetworkClientFailure() async {
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        let result = await subject.getAlbumsAndUsers()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is NetworkClientError)
            if case NetworkClientError.networkError(let status) = error {
                XCTAssertEqual(status, 404)
            } else {
                XCTFail("Incorrect Error Returned")
            }
        }
    }
    
    func test_getAlbums_BadData() async {
        mockURLSession.mockData = MockData.badData
        
        let result = await subject.getAlbums()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is DecodingError)
        }
    }
    
    func test_getUsers_BadData() async {
        mockURLSession.mockData = MockData.badData
        
        let result = await subject.getUsers()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is DecodingError)
        }
    }
    
    func test_getPhotos_BadData() async {
        mockURLSession.mockData = MockData.badData
        
        let result = await subject.getPhotos()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is DecodingError)
        }
    }
    
    func test_getAlbumsAndUsers_BadData() async {
        mockURLSession.mockData = MockData.badData
        
        let result = await subject.getAlbumsAndUsers()
        switch result {
        case .success:
            XCTFail("Unexpected Success Result!")
        case .failure(let error):
            XCTAssert(error is DecodingError)
        }
    }
}
