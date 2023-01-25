//
//  DataEndpointTests.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest
@testable import PhotoCom

final class DataEndpointTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func test_albumsEndpoint() {
        let endPointURL = DataEndpoint.albums.urlComponents.url
        XCTAssertNotNil(endPointURL)
        XCTAssertEqual(endPointURL, URL(string: "https://jsonplaceholder.typicode.com/albums"))
    }
    
    func test_usersEndpoint() {
        let endPointURL = DataEndpoint.users.urlComponents.url
        XCTAssertNotNil(endPointURL)
        XCTAssertEqual(endPointURL, URL(string: "https://jsonplaceholder.typicode.com/users"))
    }
    
    func test_photosEndpoint() {
        let endPointURL = DataEndpoint.photos.urlComponents.url
        XCTAssertNotNil(endPointURL)
        XCTAssertEqual(endPointURL, URL(string: "https://jsonplaceholder.typicode.com/photos"))
    }
}
