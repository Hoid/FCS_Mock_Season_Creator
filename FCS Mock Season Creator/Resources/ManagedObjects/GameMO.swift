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
    
    @NSManaged var id: String
    @NSManaged var contestantsNames: [String]
    @NSManaged var winnerName: String
    @NSManaged var confidence: Int
    @NSManaged var conferencesNames: [String]
    @NSManaged var week: Int
    
}

extension GameMO {
    
    public static func newGameMO(id: String?, contestants: [String]?, winner: String?, confidence: Int?, conferences: [ConferenceOptions]?, week: Int?, withContext managedContext: NSManagedObjectContext) -> GameMO? {
        
        let entity = NSEntityDescription.entity(forEntityName: "GameMO", in: managedContext)!
        let newGameMO = GameMO(entity: entity, insertInto: managedContext)
        
        if let id = id {
            newGameMO.id = id
        } else {
            newGameMO.id = UUID().uuidString
        }
        if let contestants = contestants {
            newGameMO.contestantsNames = contestants
        } else {
            newGameMO.contestantsNames = ["None", "None"]
        }
        if let winner = winner {
            newGameMO.winnerName = winner
        } else {
            newGameMO.winnerName = "None"
        }
        if let confidence = confidence {
            newGameMO.confidence = confidence
        } else {
            newGameMO.confidence = 100
        }
        if let conferences = conferences {
            newGameMO.conferencesNames.removeAll()
            for conference in conferences {
                newGameMO.conferencesNames.append(ConferenceOptions.getStringValue(conferenceOption: conference))
            }
        } else {
            newGameMO.conferencesNames.removeAll()
            newGameMO.conferencesNames.append("CAA")
        }
        if let week = week {
            newGameMO.week = week
        } else {
            newGameMO.week = 0
        }
        
        return newGameMO
    
    }
    
    public static func newGameMO(fromGame game: Game, withContext managedContext: NSManagedObjectContext) -> GameMO? {
        
        let entity = NSEntityDescription.entity(forEntityName: "GameMO", in: managedContext)!
        let newGameMO = GameMO(entity: entity, insertInto: managedContext)
        newGameMO.id = game.id
        guard let teamName1 = game.contestants.first?.name, let teamName2 = game.contestants.last?.name else {
            os_log("Could not unwrap team names in GameMO.newGameMO(fromGame:)", type: .debug)
            return nil
        }
        newGameMO.contestantsNames = [teamName1, teamName2]
        newGameMO.confidence = game.confidence
        guard let conferenceName1 = game.contestants.first?.conferenceName, let conferenceName2 = game.contestants.last?.conferenceName else {
            os_log("Could not unwrap conference names in GameMO.newGameMO(fromGame:)", type: .debug)
            return nil
        }
        newGameMO.conferencesNames = [conferenceName1, conferenceName2]
        newGameMO.week = game.week
        newGameMO.winnerName = game.winner.name
        
        return newGameMO
        
    }
    
}
