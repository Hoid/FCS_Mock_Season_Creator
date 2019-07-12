//
//  Record.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class Record: CustomStringConvertible {
    
    public var numberOfWins: Int
    public var numberOfGamesPlayed: Int
    
    private var numberOfLosses: Int {
        return self.numberOfGamesPlayed - self.numberOfWins
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
    
    init(numberOfWins: Int, numberOfGamesPlayed: Int) {
        self.numberOfWins = numberOfWins
        self.numberOfGamesPlayed = numberOfGamesPlayed
    }

    var description: String {
        return "Record: \(recordStr)"
    }
    
}
