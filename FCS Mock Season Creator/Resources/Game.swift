//
//  Game.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import CoreData

class Game: NSManagedObject {
    
    @NSManaged var contestants: [String]
    @NSManaged var winner: String
    @NSManaged var confidence: Int
    @NSManaged var conferences: [String]
    
}

extension Game {
    
    public static func newGame(context: NSManagedObjectContext, contestants: [String]?, winner: String?, confidence: Int?, conferences: [Conference]?) -> Game {
        
        let newGame = Game(context: context)
        
        if let contestants = contestants {
            newGame.contestants = contestants
        } else {
            newGame.contestants = ["", ""]
        }
        if let winner = winner {
            newGame.winner = winner
        } else {
            newGame.winner = ""
        }
        if let confidence = confidence {
            newGame.confidence = confidence
        } else {
            newGame.confidence = 0
        }
        if let conferences = conferences {
            newGame.conferences.removeAll()
            for conference in conferences {
                newGame.conferences.append(Conference.getStringValue(conference: conference))
            }
//            newGame.conferences = conferences.map({ Conference.getStringValue(conference: $0) })
        } else {
            newGame.conferences.removeAll()
            newGame.conferences.append("CAA")
        }
        
        return newGame
    
    }
    
}
