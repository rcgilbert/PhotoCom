//
//  MockData.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import Foundation
@testable import PhotoCom

class MockData {
    
    private static let jsonDecoder: JSONDecoder = .init()
    
    static var albumsData: Data? {
        loadJSON("albums")
    }
    
    static var usersData: Data? {
        loadJSON("users")
    }
    
    static var photosData: Data? {
        loadJSON("photos")
    }
    
    static var emptyRepsonse: Data {
        Data("[]".utf8)
    }
    
    static var badData: Data {
        Data("bad data;;;!!!*(DROP TABLE *".utf8)
    }
    
    static var albums: Albums? {
        guard let albumsData = albumsData else { return nil }
        return try? jsonDecoder.decode(Albums.self, from: albumsData)
    }
    
    static var users: Users? {
        guard let usersData = usersData else { return nil }
        return try? jsonDecoder.decode(Users.self, from: usersData)
    }
    
    static var photos: Photos? {
        guard let photosData = photosData else { return nil }
        return try? jsonDecoder.decode(Photos.self, from: photosData)
    }
    
    private static func loadJSON(_ name: String) -> Data? {
        guard let filePath = Bundle(for: MockData.self).url(forResource: name, withExtension: "json") else {
            return nil
        }
        
        return try? Data(contentsOf: filePath)
    }
}
