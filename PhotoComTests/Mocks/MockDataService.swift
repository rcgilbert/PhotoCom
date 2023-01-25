//
//  MockDataService.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import Foundation
@testable import PhotoCom

class MockDataService: DataServiceType {
    
    var mockAlbumsResult: Result<PhotoCom.Albums, Error> = .success([])
    func getAlbums() async -> Result<PhotoCom.Albums, Error> {
        mockAlbumsResult
    }
    
    var mockUsersResult: Result<PhotoCom.Users, Error> = .success([])
    func getUsers() async -> Result<PhotoCom.Users, Error> {
        mockUsersResult
    }
    
    var mockPhotosResult: Result<PhotoCom.Photos, Error> = .success([])
    var getPhotosCalled = false
    func getPhotos() async -> Result<PhotoCom.Photos, Error> {
        getPhotosCalled = true
        return mockPhotosResult
    }
    
    var mockAlbumsAnyUsersResult: Result<(PhotoCom.Albums, PhotoCom.Users), Error> = .success(([], []))
    var getAlbumsAndUsersCalled = false
    func getAlbumsAndUsers() async -> Result<(PhotoCom.Albums, PhotoCom.Users), Error> {
        getAlbumsAndUsersCalled = true
        return mockAlbumsAnyUsersResult
    }

}
