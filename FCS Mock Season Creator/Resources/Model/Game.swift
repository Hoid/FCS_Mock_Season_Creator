//
//  Game.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class Game: Equatable {
    
    var id: String
    var contestants: [Team]
    var winner: Team
    var confidence: Int
    var conferences: [Conference]
    var week: Int
    
    /*
     Default initializer. Should only be used to indicate an error occurred and plug a hole with a default Game object.
     */
    init() {
        
        self.id = UUID().uuidString
        let team1 = Team(teamName: "None", conferenceName: "None")
        let team2 = Team(teamName: "None", conferenceName: "None")
        self.contestants = [team1, team2]
        self.winner = team1
        self.confidence = 100
        let conference1 = Conference(name: "None", conferenceOption: .all, teams: [team1, team2])
        let conference2 = Conference(name: "None", conferenceOption: .all, teams: [team1, team2])
        self.conferences = [conference1, conference2]
        self.week = 0
        
    }
    
    init?(id: String, contestantsNames: [String], winnerName: String, confidence: Int, conferencesNames: [String], week: Int) {
        
        self.id = id
        
        guard contestantsNames.count > 0 else {
            os_log("contestantsNames had no values in Game.init()", type: .debug)
            return nil
        }
        var team1ConferenceName: String?
        var team2ConferenceName: String?
        if let team1ConferenceNameStr = Conference.name(forTeamName: contestantsNames[0]) {
            team1ConferenceName = team1ConferenceNameStr
        } else {
            os_log("Could not unwrap team1ConferenceName in Game.init()", type: .debug)
        }
        if contestantsNames.count == 2, let team2ConferenceNameStr = Conference.name(forTeamName: contestantsNames[1]) {
            team2ConferenceName = team2ConferenceNameStr
        } else {
            os_log("Could not unwrap team2ConferenceName in Game.init()", type: .debug)
        }
        let team1 = Team(teamName: contestantsNames[0], conferenceName: team1ConferenceName ?? "None")
        let team2 = Team(teamName: contestantsNames[1], conferenceName: team2ConferenceName ?? "None")
        self.contestants = [team1, team2]
        
        guard let winnerTeamConferenceName = Conference.name(forTeamName: winnerName) else {
            os_log("Could not unwrap winnerTeamConferenceName in Game.init()", type: .debug)
            return nil
        }
        self.winner = Team(teamName: winnerName, conferenceName: winnerTeamConferenceName)
        
        self.confidence = confidence
        
        self.conferences = [Conference]()
        guard let conference1 = Conference.newConference(withName: conferencesNames[0]) else {
            os_log("Could not unwrap conference1 in Game.init()", type: .debug)
            return nil
        }
        self.conferences.append(conference1)
        if conferencesNames.count == 2 {
            guard let conference2 = Conference.newConference(withName: conferencesNames[1]) else {
                os_log("Could not unwrap conference2 in Game.init()", type: .debug)
                return nil
            }
            self.conferences.append(conference2)
        }
        
        self.week = week
        
    }
    
    convenience init?(fromGameMO gameMO: GameMO) {
        
        self.init(id: gameMO.id, contestantsNames: gameMO.contestantsNames, winnerName: gameMO.winnerName, confidence: gameMO.confidence, conferencesNames: gameMO.conferencesNames, week: gameMO.week)
        
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        guard lhs.id == rhs.id else { return false }
        return true
    }
    
}
