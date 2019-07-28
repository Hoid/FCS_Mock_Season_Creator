//
//  TeamsModel.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/27/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

struct TeamsApiResponse {
    let teamNames: [String]
}

extension TeamsApiResponse: Decodable {
    
    private enum TeamsApiResponseCodingKeys: String, CodingKey {
        case teamNames = "teams"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TeamsApiResponseCodingKeys.self)
        
        teamNames = try container.decode([String].self, forKey: .teamNames)
        
    }
}


struct Teams {
    let teamNames: [String]
}

extension Teams: Decodable {
    
    enum TeamsCodingKeys: String, CodingKey {
        case teamNames = "teams"
    }
    
    
    init(from decoder: Decoder) throws {
        let teamsContainer = try decoder.container(keyedBy: TeamsCodingKeys.self)
        
        teamNames = try teamsContainer.decode([String].self, forKey: .teamNames)
    }
}
