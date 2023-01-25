//
//  MockImageService.swift
//  ANF Code TestTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import UIKit
@testable import PhotoCom

final class MockImageService: ImageServiceType {
    var mockImage: UIImage? = UIImage()
    var loadImageURL: URL?
    func loadImage(_ url: URL) async -> UIImage? {
        loadImageURL = url
        return mockImage
    }
}

