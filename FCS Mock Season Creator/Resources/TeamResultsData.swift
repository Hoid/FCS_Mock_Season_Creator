//
//  TeamResultsData.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/11/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class TeamResultsData {
    
    public var team: String
    public var games: [Game]
    
    init(team: String, games: [Game]) {
        
        self.team = team
        self.games = games
        
    }
    
    public func probOfWinningXNumberOfGames(gamesWon: Int) -> Double {
        let n = self.numberOfGamesPlayed
        let k = gamesWon
        return (fact(n) / (fact(k) * fact(n-k))) * pow(avgConfidenceToWinEachGame, Double(n)) * pow(1-avgConfidenceToWinEachGame, Double(n-k))
    }
    
    public func probOfWinningAtLeast8Games() -> Double {
        var result: Double = 0.0
        for i in 1...8 {
            result = result + probOfWinningXNumberOfGames(gamesWon: i)
        }
        return result
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
