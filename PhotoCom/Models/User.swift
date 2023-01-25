//
//  User.swift
//  PhotoCom
//
//  Created by Ryan Gilbert on 1/25/23.
//

import Foundation

typealias Users = [User]

// MARK: - User
struct User: Codable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone, website: String
    let company: Company
}

// MARK: - Address
struct Address: Codable, Equatable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}

// MARK: - Geo
struct Geo: Codable, Equatable {
    let lat: String
    let lng: String
}

// MARK: - Company
struct Company: Codable, Equatable {
    let name: String
    let catchPhrase: String
    let bs: String
}

