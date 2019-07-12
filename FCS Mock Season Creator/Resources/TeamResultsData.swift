//
//  TeamResultsData.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/11/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class TeamResultsData {
    
    public var teamName: String
    public var games: [Game]
    
    init(teamName: String, games: [Game]) {
        
        self.teamName = teamName
        self.games = games
        
    }
    
    public func calculateProbOfWinningXNumberOfGames(gamesWon: Int) -> Double {
        let n = self.numberOfGamesPlayed
        let k = gamesWon
        return (fact(n) / (fact(k) * fact(n-k))) * pow(avgConfidenceToWinEachGame, Double(n)) * pow(1-avgConfidenceToWinEachGame, Double(n-k))
    }
    
    public func calculateProbOfWinningAtLeast8Games() -> Double {
        var result: Double = 0.0
        for i in 8...numberOfGamesPlayed {
            result = result + calculateProbOfWinningXNumberOfGames(gamesWon: i)
        }
        return result
    }
    
    public func calculateMostLikelyRecord() -> Record {
        var possibleRecordsAndLikelihoods = [(Record, Double)]()
        for i in 0...numberOfGamesPlayed {
            let record = Record(numberOfWins: i, numberOfGamesPlayed: numberOfGamesPlayed)
            possibleRecordsAndLikelihoods.append((record, calculateProbOfWinningXNumberOfGames(gamesWon: i)))
        }
        possibleRecordsAndLikelihoods.sort(by: { $0.1 > $1.1 })
        let mostLikelyRecord = possibleRecordsAndLikelihoods[0].0
        return mostLikelyRecord
    }
    
    private var numberOfGamesPlayed: Int {
        return games.count
    }
    
    private var avgConfidenceToWinEachGame: Double {
        let confidences: [Int] = self.games.map({ $0.confidence })
        return Double(confidences.reduce(0,+))/Double(confidences.count)
    }
    
    // helper function for calculating the factorial of a number
    private func fact(_ n: Int) -> Double {
        if n == 0 {
            return 1
        }
        var a: Double = 1
        for i in 1...n {
            a *= Double(i)
        }
        return a
    }
    
}
