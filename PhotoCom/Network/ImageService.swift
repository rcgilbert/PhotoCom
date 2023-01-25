//
//  ImageService.swift
//  ANF Code Test
//
//  Created by Ryan Gilbert on 1/25/23.
//

import UIKit

protocol ImageServiceType {
    func loadImage(_ url: URL) async -> UIImage?
}

final class ImageService: ImageServiceType {
    static let shared: ImageService = .init()
    
    private let imageCache: NSCache<NSURL, UIImage> = NSCache()
    private let urlSession: URLSessionType
    
    init(urlSession: URLSessionType = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func loadImage(_ url: URL) async -> UIImage? {
        // Check cache first
        if let image = imageCache.object(forKey: url as NSURL) {
            return image
        }
        
        // Go to network
        if let (data, _) = try? await urlSession.data(for: URLRequest(url: url)) {
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: url as NSURL)
                return image
            }
        }
       
        return nil
    }
}
