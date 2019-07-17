//
//  ConferenceResultsData.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class ConferenceResultsData {
    
    private var conference: Conference
    private var games: [Game]
    private var teamResults = [TeamResultsData]()
    
    init(conference: Conference, games: [Game]) {
        
        self.conference = conference
        self.games = games
        
        for team in conference.teams {
            let gamesPlayedByTeam = self.games.filter({ $0.contestants.contains(team) })
            self.teamResults.append(TeamResultsData(teamName: team.name, games: gamesPlayedByTeam))
        }
        
    }
    
    public func calculateConferenceSeasonResult() -> ConferenceSeasonResult {
        
        return ConferenceSeasonResult(conference: self.conference, teamResults: self.teamResults)
        
    }
    
}
