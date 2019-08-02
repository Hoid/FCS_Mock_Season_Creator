//
//  GamesApi.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/18/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

public enum GamesApi {
    case games
    case gamesNew
}

extension GamesApi: EndPointType {
    
    var environmentBaseURL : String {
        let teamsByConferenceNetworkManager = TeamsByConferenceNetworkManager()
        switch teamsByConferenceNetworkManager.environment {
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
        case .games:
            return "games"
        case .gamesNew:
            return "new/games"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .games:
            return .get
        case .gamesNew:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .games, .gamesNew:
            return .requestWithParameters(bodyParameters: nil, urlParameters: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
