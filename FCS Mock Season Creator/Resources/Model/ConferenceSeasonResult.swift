//
//  ConferenceSeasonResult.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class ConferenceSeasonResult {
    
    public var conference: Conference
    public var placementMappedToResults = [Int : (String, Double, Record)]()
    
    init?(conference: Conference, teamResults: [TeamResultsData]) {
        let teamsConferences = teamResults.map({ Conference.name(forTeamName: $0.teamName) })
        let teamsUniqueConferences = Array(Set(teamsConferences))
        if teamsUniqueConferences.count > 1 || teamsUniqueConferences.count < 1 {
            os_log("All teams are not in the same conference in ConferenceSeasonResult.init()", type: .debug)
            print("Teams: ")
            print(teamResults.map({ $0.teamName }))
            print("Teams conferences: ")
            print(teamsConferences)
            print("Unique conferences: ")
            print(teamsUniqueConferences)
            return nil
        }
        self.conference = conference
        var results = [(String, Double, Record)]()
        for teamResult in teamResults {
            let mostLikelyRecord = teamResult.calculateMostLikelyRecord()
            let likelihoodToWinEachGame = teamResult.avgConfidenceToWinEachGame
            results.append((teamResult.teamName, likelihoodToWinEachGame, mostLikelyRecord))
        }
        let sortedResults = results.sorted { (tuple1, tuple2) -> Bool in
            if tuple1.2.numberOfWins != tuple2.2.numberOfWins {
                return tuple1.2.numberOfWins > tuple2.2.numberOfWins
            } else if tuple1.2.numberOfLosses != tuple2.2.numberOfLosses {
                return tuple1.2.numberOfLosses < tuple2.2.numberOfLosses
            } else {
                return tuple1.1 > tuple2.1
            }
        }
        for (index, teamNameAndLikelihoodOfWinningEachGameAndRecord) in sortedResults.enumerated() {
            self.placementMappedToResults[index] = teamNameAndLikelihoodOfWinningEachGameAndRecord
        }
    }
    
}
