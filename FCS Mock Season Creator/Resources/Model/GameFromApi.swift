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
    var winner: Team?
    var homeTeam: Team
    var awayTeam: Team
    var homeConference: Conference
    var awayConference: Conference
    var avgConfidence: Double
    var avgHomeTeamScore: Double
    var avgAwayTeamScore: Double
    var week: Int
    
    var contestants: [Team] {
        return [awayTeam, homeTeam]
    }
    
    var conferences: [Conference] {
        return [awayConference, homeConference]
    }
    
    /*
     Default initializer. Should only be used to indicate an error occurred and plug a hole with a default Game object.
     */
    init() {
        
        self.id = Int.random(in: 1...65535)
        let team1 = Team(teamName: "None", conferenceName: "None")
        let team2 = Team(teamName: "None", conferenceName: "None")
        self.homeTeam = team1
        self.awayTeam = team2
        self.winner = team1
        self.avgConfidence = 0
        self.avgHomeTeamScore = 50.0
        self.avgAwayTeamScore = 50.0
        self.homeConference = Conference(name: "None", conferenceOption: .none, teams: [team1, team2])
        self.awayConference = Conference(name: "None", conferenceOption: .none, teams: [team1, team2])
        self.week = 0
        
    }
    
    init?(id: Int, homeTeamName: String, awayTeamName: String, winnerName: String?, avgConfidence: Double, homeConferenceName: String, awayConferenceName: String, avgHomeTeamScore: Double, avgAwayTeamScore: Double, week: Int) {
        
        self.id = id
        self.avgConfidence = avgConfidence
        self.week = week
        self.avgHomeTeamScore = avgHomeTeamScore
        self.avgAwayTeamScore = avgAwayTeamScore
        
        guard let homeConference = Conference(withName: homeConferenceName) else {
            os_log("Could not unwrap homeConference in Game.init()", type: .debug)
            return nil
        }
        guard let awayConference = Conference(withName: awayConferenceName) else {
            os_log("Could not unwrap awayConference in Game.init()", type: .debug)
            return nil
        }
        self.homeConference = homeConference
        self.awayConference = awayConference
        self.homeTeam = Team(teamName: homeTeamName, conferenceName: homeConference.name)
        self.awayTeam = Team(teamName: awayTeamName, conferenceName: awayConference.name)
        
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
