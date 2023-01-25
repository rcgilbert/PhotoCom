//
//  Endpoint.swift
//  ANF Code Test
//
//  Created by Ryan Gilbert on 1/18/23.
//

import Foundation

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    
    // Add additional properties such as method, header, body, etc. as needed
}

extension Endpoint {
    // -- Add default implementations for simplicity
    var scheme: String {
        "https"
    }
    
    var host: String {
        "jsonplaceholder.typicode.com"
    }
    // --

    var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        
        return urlComponents
    }
}
