//
//  DataEndpoint.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import Foundation

enum DataEndpoint: String, Endpoint {
    case albums
    case users
    case photos
    
    var path: String {
        switch self {
        case .albums:
            return "/albums"
        case .users:
            return "/users"
        case .photos:
            return "/photos"
        }
    }
}
