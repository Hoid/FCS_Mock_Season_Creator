//
//  File.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 8/22/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import CoreData

class GameMOMapping: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        if sInstance.entity.name == "GameMO" {
            let conferencesNames = sInstance.primitiveValue(forKey: "conferencesNames") as! [String]
            let confidence = sInstance.primitiveValue(forKey: "confidence") as! Int
            let contestantsNames = sInstance.primitiveValue(forKey: "contestantsNames") as! [String]
            let id = sInstance.primitiveValue(forKey: "id") as! Int
            let week = sInstance.primitiveValue(forKey: "week") as! Int
            let winnerName = sInstance.primitiveValue(forKey: "winnerName") as! String
            
            let newGameMO = NSEntityDescription.insertNewObject(forEntityName: "GameMO", into: manager.destinationContext)
            newGameMO.setValue(0.0, forKey: "avgAwayTeamScore")
            newGameMO.setValue(50.0, forKey: "avgConfidence")
            newGameMO.setValue(0.0, forKey: "avgHomeTeamScore")
            newGameMO.setValue(conferencesNames[0], forKey: "awayConferenceName")
            newGameMO.setValue(contestantsNames[0], forKey: "awayTeamName")
            newGameMO.setValue(0, forKey: "awayTeamScore")
            newGameMO.setValue(confidence, forKey: "confidence")
            newGameMO.setValue(conferencesNames[1], forKey: "homeConferenceName")
            newGameMO.setValue(contestantsNames[1], forKey: "homeTeamName")
            newGameMO.setValue(0, forKey: "homeTeamScore")
            newGameMO.setValue(id, forKey: "id")
            newGameMO.setValue(week, forKey: "week")
            newGameMO.setValue(winnerName, forKey: "winnerName")
        }
    }
    
}
