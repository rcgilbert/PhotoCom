//
//  MockURLSession.swift
//  ANF Code TestTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import Foundation
@testable import PhotoCom

final class MockURLSession: URLSessionType {
    var mockData: Data = Data()
    var mockResponse: URLResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                    statusCode: 200,
                                                    httpVersion: nil,
                                                    headerFields: nil)!
    var urlRequest: URLRequest?
    
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        self.urlRequest = urlRequest
        return (mockData, mockResponse)
    }
}
