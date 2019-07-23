//
//  FCSSeasonResult.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class FCSSeasonResult {
    
    public var sortedTeamsAndRecords = [(String, Record)]()
    
    init(teamResults: [TeamResultsData]) {
        var teamNamesAndRecords = [(String, Record)]()
        for teamResult in teamResults {
            guard let conferenceName = Conference.name(forTeamName: teamResult.teamName) else {
                os_log("Could not unwrap conference in FCSSeasonResult.init()", type: .debug)
                continue
            }
            guard conferenceName != "None" else {
                continue
            }
            let mostLikelyRecord = teamResult.calculateMostLikelyRecord()
            teamNamesAndRecords.append((teamResult.teamName, mostLikelyRecord))
        }
        self.sortedTeamsAndRecords = teamNamesAndRecords.sorted(by: { $0.1.percentOfGamesWon > $1.1.percentOfGamesWon })
    }
    
}
