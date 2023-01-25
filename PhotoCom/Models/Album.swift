//
//  Album.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import Foundation

typealias Albums = [Album]

// MARK: - Album
struct Album: Codable, Equatable {
    let userID: Int
    let id: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title
    }
}
