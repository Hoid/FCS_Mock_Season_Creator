//
//  Game.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import os.log

class GameMO: NSManagedObject {
    
    @NSManaged var avgAwayTeamScore: Double
    @NSManaged var avgConfidence: Double
    @NSManaged var avgHomeTeamScore: Double
    @NSManaged var awayConferenceName: String
    @NSManaged var awayTeamName: String
    @NSManaged var awayTeamScore: Int
    @NSManaged var confidence: Int
    @NSManaged var homeConferenceName: String
    @NSManaged var homeTeamName: String
    @NSManaged var homeTeamScore: Int
    @NSManaged var id: Int
    @NSManaged var week: Int
    @NSManaged var winnerName: String
    
}

extension GameMO {
    
    public static func newGameMO(fromGame game: Game, withContext managedContext: NSManagedObjectContext) -> GameMO {
        
        let entity = NSEntityDescription.entity(forEntityName: "GameMO", in: managedContext)!
        let newGameMO = GameMO(entity: entity, insertInto: managedContext)
        newGameMO.avgAwayTeamScore = game.avgAwayTeamScore
        newGameMO.avgConfidence = game.avgConfidence
        newGameMO.avgHomeTeamScore = game.avgHomeTeamScore
        newGameMO.awayConferenceName = game.awayConference.name
        newGameMO.awayTeamName = game.awayTeam.name
        newGameMO.awayTeamScore = game.awayTeamScore
        newGameMO.confidence = game.confidence
        newGameMO.homeConferenceName = game.homeConference.name
        newGameMO.homeTeamName = game.homeTeam.name
        newGameMO.homeTeamScore = game.homeTeamScore
        newGameMO.id = game.id
        newGameMO.week = game.week
        newGameMO.winnerName = game.winner.name
        
        return newGameMO
        
    }
    
}
