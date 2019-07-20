//
//  GamesModel.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/18/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

struct GamesApiResponse {
    let games: [GameApiResponse]
}

extension GamesApiResponse: Decodable {
    
    private enum GamesApiResponseCodingKeys: String, CodingKey {
        case games = "games"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GamesApiResponseCodingKeys.self)
        
        games = try container.decode([GameApiResponse].self, forKey: .games)
        
    }
    
}

struct GameApiResponse {
    let contestants: [String]
    let week: String
}

extension GameApiResponse: Decodable {
    
    private enum GameApiResponseCodingKeys: String, CodingKey {
        case contestants = "contestants"
        case week = "week"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameApiResponseCodingKeys.self)
        
        contestants = try container.decode([String].self, forKey: .contestants)
        week = try container.decode(String.self, forKey: .week)
        
    }
    
}
