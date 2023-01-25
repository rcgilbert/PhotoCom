//
//  NetworkClient.swift
//  ANF Code Test
//
//  Created by Ryan Gilbert on 1/25/23.
//

import Foundation

protocol NetworkClient {
    func sendRequest<T: Decodable>(endPoint: Endpoint, urlSession: URLSessionType, decoder: JSONDecoder) async -> Result<T, Error>
}

extension NetworkClient {
    func sendRequest<T: Decodable>(endPoint: Endpoint, urlSession: URLSessionType = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) async -> Result<T, Error> {
        guard let url = endPoint.urlComponents.url else {
            return .failure(NetworkClientError.invalidURL)
        }
        
        let request = URLRequest(url: url)
        do {
            let (data, response) = try await urlSession.data(for: request)
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200...299:
                    return decode(data: data, decoder: decoder)
                default:
                    return .failure(NetworkClientError.networkError(status: response.statusCode))
                    
                }
            } else {
                return .failure(NetworkClientError.unsupportedResponse)
            }
            
        } catch {
            return .failure(error)
        }
    }
    
    private func decode<T: Decodable>(data: Data, decoder: JSONDecoder) -> Result<T, Error> {
        do {
            let decodedData: T = try decoder.decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - URLSession

/// Protocol to allow for mocking of URLSession calls
protocol URLSessionType {
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionType { }

// MARK: - Errors
enum NetworkClientError: Error {
    case invalidURL
    case noResponse
    case networkError(status: Int)
    case unsupportedResponse
}
