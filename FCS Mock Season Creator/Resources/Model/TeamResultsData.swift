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
        if gamesWon > self.numberOfGamesPlayed {
            return 0.0
        }
        let n = self.numberOfGamesPlayed
        let k = gamesWon
        return (fact(n) / (fact(k) * fact(n-k))) * pow(avgConfidenceToWinEachGame, Double(k)) * pow(1.0-avgConfidenceToWinEachGame, Double(n-k))
    }
    
    public func calculateProbOfWinningAtLeast8Games() -> Double {
        var result: Double = 0.0
        if numberOfGamesPlayed < 8 {
            return 0.0
        }
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
    
    public var numberOfGamesPlayed: Int {
        return games.count
    }
    
    // "Normalized" in this context means it takes into account the winner of the game
    public var avgConfidenceToWinEachGame: Double {
        let confidencesAndTeams: [(Int, Team)] = self.games.map({ ($0.confidence, $0.winner) })
        let normalizedConfidences = confidencesAndTeams.map { (confidence, winner) -> Double in
            var normalizedConfidence: Int = 0
            if winner.name != self.teamName {
                normalizedConfidence = 100 - confidence
            } else {
                normalizedConfidence = confidence
            }
            return Double(normalizedConfidence) / 100.0
        }
        return Double(normalizedConfidences.reduce(0,+))/Double(normalizedConfidences.count)
    }
    
    public var possibleRecords: [Record] {
        var possibleRecordsData = [Record]()
        for i in 0...numberOfGamesPlayed {
            let record = Record(numberOfWins: i, numberOfGamesPlayed: numberOfGamesPlayed)
            possibleRecordsData.append(record)
        }
        possibleRecordsData.sort { (record1, record2) -> Bool in
            return record1.numberOfWins > record2.numberOfWins
        }
        return possibleRecordsData
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
