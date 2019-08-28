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
    let id: Int
    let homeTeam: String
    let awayTeam: String
    let week: Int
    let avgConfidence: Double
    let avgHomeTeamScore: Double
    let avgAwayTeamScore: Double
    let winner: String?
}

extension GameApiResponse: Decodable {
    
    private enum GameApiResponseCodingKeys: String, CodingKey {
        case id = "id"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case week = "week"
        case avgConfidence = "avg_confidence"
        case avgHomeTeamScore = "avg_home_score"
        case avgAwayTeamScore = "avg_away_score"
        case winner = "winner"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: GameApiResponseCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        homeTeam = try container.decode(String.self, forKey: .homeTeam)
        awayTeam = try container.decode(String.self, forKey: .awayTeam)
        week = try container.decode(Int.self, forKey: .week)
        avgConfidence = try container.decode(Double.self, forKey: .avgConfidence)
        avgHomeTeamScore = try container.decode(Double.self, forKey: .avgHomeTeamScore)
        avgAwayTeamScore = try container.decode(Double.self, forKey: .avgAwayTeamScore)
        winner = try container.decodeIfPresent(String.self, forKey: .winner)
        
    }
    
}

struct GamesOldApiResponse {
    let games: [GameOldApiResponse]
}

extension GamesOldApiResponse: Decodable {
    
    private enum GamesOldApiResponseCodingKeys: String, CodingKey {
        case games = "games"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: GamesOldApiResponseCodingKeys.self)
        
        games = try container.decode([GameOldApiResponse].self, forKey: .games)
        
    }
    
}

struct GameOldApiResponse {
    let id: Int
    let contestants: [String]
    let week: Int
    let winner: String?
}

extension GameOldApiResponse: Decodable {
    
    private enum GameOldApiResponseCodingKeys: String, CodingKey {
        case id = "id"
        case contestants = "contestants"
        case week = "week"
        case winner = "winner"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: GameOldApiResponseCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        contestants = try container.decode([String].self, forKey: .contestants)
        week = try container.decode(Int.self, forKey: .week)
        winner = try container.decodeIfPresent(String.self, forKey: .winner)
        
    }
    
}
