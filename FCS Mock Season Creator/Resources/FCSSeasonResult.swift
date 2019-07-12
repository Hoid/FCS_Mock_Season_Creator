//
//  FCSSeasonResult.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class FCSSeasonResult {
    
    public var placementMappedToTeamAndRecord = [Int : (String, Record)]()
    
    init(teamResults: [TeamResultsData]) {
        var teamNamesAndRecords = [(String, Record)]()
        for teamResult in teamResults {
            let mostLikelyRecord = teamResult.calculateMostLikelyRecord()
            teamNamesAndRecords.append((teamResult.teamName, mostLikelyRecord))
        }
        let sortedTeamNamesAndRecords = teamNamesAndRecords.sorted(by: { $0.1.percentOfGamesWon > $1.1.percentOfGamesWon })
        for (index, teamNameAndRecord) in sortedTeamNamesAndRecords.enumerated() {
            self.placementMappedToTeamAndRecord[index] = teamNameAndRecord
        }
    }
    
}
