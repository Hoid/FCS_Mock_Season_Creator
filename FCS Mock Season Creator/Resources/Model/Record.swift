//
//  Record.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class Record: Equatable, CustomStringConvertible {
    
    public var numberOfWins: Int
    public var numberOfGamesPlayed: Int
    
    init(numberOfWins: Int, numberOfGamesPlayed: Int) {
        
        self.numberOfWins = numberOfWins
        self.numberOfGamesPlayed = numberOfGamesPlayed
        
    }
    
    static func == (lhs: Record, rhs: Record) -> Bool {
        guard lhs.numberOfWins == rhs.numberOfWins else { return false }
        guard lhs.numberOfGamesPlayed == rhs.numberOfGamesPlayed else { return false }
        return true
    }
    
    public var recordStr: String {
        return String(format: "%d-%d", numberOfWins, numberOfLosses)
    }
    
    public var percentOfGamesWon: Double {
        if numberOfWins == 0 || numberOfGamesPlayed == 0 {
            return 0.0
        } else {
            return Double(numberOfWins) / Double(numberOfGamesPlayed)
        }
    }
    
    public var numberOfLosses: Int {
        return self.numberOfGamesPlayed - self.numberOfWins
    }
    
    var description: String {
        return "Record: \(recordStr)"
    }
    
}
