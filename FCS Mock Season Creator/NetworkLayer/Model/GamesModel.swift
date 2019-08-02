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
    let week: Int
    let winner: String?
}

extension GameApiResponse: Decodable {
    
    private enum GameApiResponseCodingKeys: String, CodingKey {
        case contestants = "contestants"
        case week = "week"
        case winner = "winner"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameApiResponseCodingKeys.self)
        
        contestants = try container.decode([String].self, forKey: .contestants)
        week = try container.decode(Int.self, forKey: .week)
        winner = try container.decode(String?.self, forKey: .winner)
        
    }
    
}

struct GamesNewApiResponse {
    let games: [GameNewApiResponse]
}

extension GamesNewApiResponse: Decodable {
    
    private enum GamesNewApiResponseCodingKeys: String, CodingKey {
        case games = "games"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GamesNewApiResponseCodingKeys.self)
        
        games = try container.decode([GameNewApiResponse].self, forKey: .games)
        
    }
    
}

struct GameNewApiResponse {
    let id: Int
    let contestants: [String]
    let week: Int
    let winner: String?
}

extension GameNewApiResponse: Decodable {
    
    private enum GameNewApiResponseCodingKeys: String, CodingKey {
        case id = "id"
        case contestants = "contestants"
        case week = "week"
        case winner = "winner"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameNewApiResponseCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        contestants = try container.decode([String].self, forKey: .contestants)
        week = try container.decode(Int.self, forKey: .week)
        winner = try container.decode(String?.self, forKey: .winner)
        
    }
    
}
