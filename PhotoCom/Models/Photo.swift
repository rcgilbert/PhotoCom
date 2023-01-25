//
//  Photo.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import Foundation

typealias Photos = [Photo]

// MARK: - Photo
struct Photo: Codable, Equatable {
    let albumID: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case albumID = "albumId"
        case id, title, url
        case thumbnailURL = "thumbnailUrl"
    }
}
