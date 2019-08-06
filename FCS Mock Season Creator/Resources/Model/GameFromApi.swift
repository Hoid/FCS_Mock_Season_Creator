//
//  GameFromApi.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 8/5/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class GameFromApi {
    
    var id: Int
    var contestants: [Team]
    var winner: Team?
    var confidence: Int
    var conferences: [Conference]
    var week: Int
    
    /*
     Default initializer. Should only be used to indicate an error occurred and plug a hole with a default Game object.
     */
    init() {
        
        self.id = 0
        let team1 = Team(teamName: "None", conferenceName: "None")
        let team2 = Team(teamName: "None", conferenceName: "None")
        self.contestants = [team1, team2]
        self.winner = team1
        self.confidence = 0
        let conference1 = Conference(name: "None", conferenceOption: .none, teams: [team1, team2])
        let conference2 = Conference(name: "None", conferenceOption: .none, teams: [team1, team2])
        self.conferences = [conference1, conference2]
        self.week = 0
        
    }
    
    init?(id: Int, contestantsNames: [String], winnerName: String?, confidence: Int, conferencesNames: [String], week: Int) {
        
        self.id = id
        self.confidence = confidence
        self.week = week
        
        guard contestantsNames.count > 0 else {
            os_log("contestantsNames had no values in Game.init()", type: .debug)
            return nil
        }
        guard let team1Conference = Conference.newConference(withTeamName: contestantsNames[0]) else {
            os_log("Could not unwrap team1Conference in Game.init()", type: .debug)
            return nil
        }
        guard let team2Conference = Conference.newConference(withTeamName: contestantsNames[1]) else {
            os_log("Could not unwrap team2Conference in Game.init()", type: .debug)
            return nil
        }
        let team1 = Team(teamName: contestantsNames[0], conferenceName: team1Conference.name)
        let team2 = Team(teamName: contestantsNames[1], conferenceName: team2Conference.name)
        self.contestants = [team1, team2]
        self.conferences = [team1Conference, team2Conference]
        
        if let winnerName = winnerName {
            guard let winnerTeamConferenceName = Conference.name(forTeamName: winnerName) else {
                os_log("Could not unwrap winnerTeamConferenceName in Game.init()", type: .debug)
                return nil
            }
            self.winner = Team(teamName: winnerName, conferenceName: winnerTeamConferenceName)
        } else {
            self.winner = nil
        }
        
    }
    
}
