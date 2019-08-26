//
//  Game.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class Game: Equatable, CustomStringConvertible {
    
    var id: Int
    var winner: Team
    var homeTeam: Team
    var awayTeam: Team
    var homeConference: Conference
    var awayConference: Conference
    var confidence: Int
    var homeTeamScore: Int
    var awayTeamScore: Int
    var avgConfidence: Double
    var avgHomeTeamScore: Double
    var avgAwayTeamScore: Double
    var week: Int
    
    var score: String {
        if homeTeamScore >= awayTeamScore {
            return "\(homeTeamScore)-\(awayTeamScore)"
        } else {
            return "\(awayTeamScore)-\(homeTeamScore)"
        }
    }
    
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
        self.confidence = 0
        self.homeConference = Conference(name: "None", conferenceOption: .none, teams: [team1, team2])
        self.awayConference = Conference(name: "None", conferenceOption: .none, teams: [team1, team2])
        self.homeTeamScore = 0
        self.awayTeamScore = 0
        self.avgConfidence = 50.0
        self.avgHomeTeamScore = 0.0
        self.avgAwayTeamScore = 0.0
        self.week = 0
        
    }
    
    init(id: Int, homeTeam: Team, awayTeam: Team, winner: Team, confidence: Int, homeConference: Conference, awayConference: Conference, homeTeamScore: Int, awayTeamScore: Int, avgConfidence: Double, avgHomeTeamScore: Double, avgAwayTeamScore: Double, week: Int) {
        
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.winner = winner
        self.confidence = confidence
        self.homeConference = homeConference
        self.awayConference = awayConference
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.avgConfidence = avgConfidence
        self.avgHomeTeamScore = avgHomeTeamScore
        self.avgAwayTeamScore = avgAwayTeamScore
        self.week = week
        
    }
    
    init?(id: Int, homeTeamName: String, awayTeamName: String, winnerName: String, confidence: Int, homeConferenceName: String, awayConferenceName: String, homeTeamScore: Int, awayTeamScore: Int, avgConfidence: Double, avgHomeTeamScore: Double, avgAwayTeamScore: Double, week: Int) {
        
        self.id = id
        
        let homeTeamConferenceNameStr = Conference.name(forTeamName: homeTeamName)
        let awayTeamConferenceNameStr = Conference.name(forTeamName: awayTeamName)
        let homeTeam = Team(teamName: homeTeamName, conferenceName: homeTeamConferenceNameStr ?? "None")
        let awayTeam = Team(teamName: awayTeamName, conferenceName: awayTeamConferenceNameStr ?? "None")
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        
        guard let winnerTeamConferenceName = Conference.name(forTeamName: winnerName) else {
            os_log("Could not unwrap winnerTeamConferenceName in Game.init()", type: .debug)
            return nil
        }
        self.winner = Team(teamName: winnerName, conferenceName: winnerTeamConferenceName)
        
        self.confidence = confidence
        
        guard let homeConference = Conference(withName: homeConferenceName) else {
            os_log("Could not unwrap conference1 in Game.init()", type: .debug)
            return nil
        }
        self.homeConference = homeConference
        guard let awayConference = Conference(withName: awayConferenceName) else {
            os_log("Could not unwrap conference2 in Game.init()", type: .debug)
            return nil
        }
        self.awayConference = awayConference
        
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.avgConfidence = avgConfidence
        self.avgHomeTeamScore = avgHomeTeamScore
        self.avgAwayTeamScore = avgAwayTeamScore
        self.week = week
        
    }
    
    convenience init?(fromGameMO gameMO: GameMO) {
        
        self.init(id: gameMO.id, homeTeamName: gameMO.homeTeamName, awayTeamName: gameMO.awayTeamName, winnerName: gameMO.winnerName, confidence: gameMO.confidence, homeConferenceName: gameMO.homeConferenceName, awayConferenceName: gameMO.awayConferenceName, homeTeamScore: gameMO.homeTeamScore, awayTeamScore: gameMO.awayTeamScore, avgConfidence: gameMO.avgConfidence, avgHomeTeamScore: gameMO.avgHomeTeamScore, avgAwayTeamScore: gameMO.avgAwayTeamScore, week: gameMO.week)
        
    }
    
    convenience init(fromGameFromApi gameFromApi: GameFromApi) {
        
        self.init(id: gameFromApi.id, homeTeam: gameFromApi.homeTeam, awayTeam: gameFromApi.awayTeam, winner: gameFromApi.winner ?? gameFromApi.awayTeam, confidence: 50, homeConference: gameFromApi.homeConference, awayConference: gameFromApi.awayConference, homeTeamScore: 0, awayTeamScore: 0, avgConfidence: gameFromApi.avgConfidence, avgHomeTeamScore: gameFromApi.avgHomeTeamScore, avgAwayTeamScore: gameFromApi.avgAwayTeamScore, week: gameFromApi.week)
        
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        guard lhs.id == rhs.id else { return false }
        return true
    }
    
    var description: String {
        
        return "(Id: \(self.id), Contestants: (\(self.homeTeam), \(self.awayTeam), Winner: \(self.winner), Score: \(homeTeamScore)-\(awayTeamScore), Confidence: \(self.confidence), Week: \(self.week))"
        
    }
    
}
