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
    
    public static func newGameMO(id: String?, contestants: [String]?, winner: String?, confidence: Int?, conferences: [ConferenceOptions]?, week: Int?) -> GameMO? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newGame = GameMO(context: managedContext)
        
        if let id = id {
            newGame.id = id
        } else {
            newGame.id = UUID().uuidString
        }
        if let contestants = contestants {
            newGame.contestantsNames = contestants
        } else {
            newGame.contestantsNames = ["None", "None"]
        }
        if let winner = winner {
            newGame.winnerName = winner
        } else {
            newGame.winnerName = "None"
        }
        if let confidence = confidence {
            newGame.confidence = confidence
        } else {
            newGame.confidence = 0
        }
        if let conferences = conferences {
            newGame.conferencesNames.removeAll()
            for conference in conferences {
                newGame.conferencesNames.append(ConferenceOptions.getStringValue(conferenceOption: conference))
            }
        } else {
            newGame.conferencesNames.removeAll()
            newGame.conferencesNames.append("CAA")
        }
        if let week = week {
            newGame.week = week
        } else {
            newGame.week = 0
        }
        
        return newGame
    
    }
    
    public static func newGameMO(fromGame game: Game) -> GameMO? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let gameMO = GameMO(context: managedContext)
        gameMO.id = game.id
        guard let teamName1 = game.contestants.first?.name, let teamName2 = game.contestants.last?.name else {
            os_log("Could not unwrap team names in GameMO.newGameMO(fromGame:)", type: .debug)
            return nil
        }
        gameMO.contestantsNames = [teamName1, teamName2]
        gameMO.confidence = game.confidence
        guard let conferenceName1 = game.contestants.first?.conferenceName, let conferenceName2 = game.contestants.last?.conferenceName else {
            os_log("Could not unwrap conference names in GameMO.newGameMO(fromGame:)", type: .debug)
            return nil
        }
        gameMO.conferencesNames = [conferenceName1, conferenceName2]
        gameMO.week = game.week
        gameMO.winnerName = game.winner.name
        
        return gameMO
        
    }
    
}
