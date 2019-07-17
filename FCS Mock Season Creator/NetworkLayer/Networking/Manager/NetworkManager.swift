//
//  NetworkManager.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/13/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

protocol NetworkManager {
    
    associatedtype DataType: EndPointType
    
    var environment: NetworkEnvironment { get }
    var router: Router<DataType> { get set }
    
}

extension NetworkManager {
    
    public func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
        
    }
    
}

enum NetworkResponse: String {
    
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request."
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    
}

enum Result<String> {
    
    case success
    case failure(String)

}
