//
//  TeamsApi.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/27/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

public enum TeamsApi {
    case teams
}

extension TeamsApi: EndPointType {
    
    var environmentBaseURL : String {
        let teamsNetworkManager = TeamsNetworkManager()
        switch teamsNetworkManager.environment {
        case .production: return "http://fcsmockseasoncreatorserver-env.phpkqsnwm2.us-east-1.elasticbeanstalk.com/"
        case .qa: return "http://fcsmockseasoncreatorserver-env.phpkqsnwm2.us-east-1.elasticbeanstalk.com/"
        case .staging: return "http://fcsmockseasoncreatorserver-env.phpkqsnwm2.us-east-1.elasticbeanstalk.com/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .teams:
            return "teams"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .teams:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .teams:
            return .requestWithParameters(bodyParameters: nil, urlParameters: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
