//
//  DataService.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import Foundation

protocol DataServiceType {
    func getAlbums() async -> Result<Albums, Error>
    func getUsers() async -> Result<Users, Error>
    func getPhotos() async -> Result<Photos, Error>
    func getAlbumsAndUsers() async -> Result<(Albums, Users), Error>
}

final class DataService: DataServiceType, NetworkClient {
    private let urlSession: URLSessionType
    
    init(urlSession: URLSessionType = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    
    func getAlbums() async -> Result<Albums, Error> {
        await sendRequest(endPoint: DataEndpoint.albums, urlSession: urlSession)
    }
    
    func getUsers() async -> Result<Users, Error> {
        await sendRequest(endPoint: DataEndpoint.users, urlSession: urlSession)
    }
    
    func getPhotos() async -> Result<Photos, Error> {
        await sendRequest(endPoint: DataEndpoint.photos, urlSession: urlSession)
    }
    
    func getAlbumsAndUsers() async -> Result<(Albums, Users), Error> {
        await withTaskGroup(of: Result<(Albums, Users), Error>.self) { group in
            group.addTask {
                let albums = await self.getAlbums()
                return albums.map { ($0, Users()) }
            }
            
            group.addTask {
                let users = await self.getUsers()
                return users.map { (Albums(), $0) }
            }
            
            var allUsers = Users()
            var allAlbums = Albums()
            for await result in group {
                switch result {
                case .success((let albums, let users)):
                    allAlbums.append(contentsOf: albums)
                    allUsers.append(contentsOf: users)
                case .failure:
                    return result
                }
            }
            
            return .success((allAlbums, allUsers))
        }
    }
}

