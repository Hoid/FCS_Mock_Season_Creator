//
//  Conference.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

class Conference: Equatable {
    
    var name: String
    var conferenceOption: ConferenceOptions
    var teams = [Team]()
    
    init(name: String, conferenceOption: ConferenceOptions?, teams: [Team]) {
        
        self.name = name
        if let conferenceOption = conferenceOption {
            self.conferenceOption = conferenceOption
        } else {
            self.conferenceOption = ConferenceOptions.getEnumValueFromStringValue(conferenceStr: name)
        }
        self.teams = teams
        
    }
    
    convenience init?(fromConferenceMO conferenceMO: ConferenceMO) {
        
        let teamsInConference = conferenceMO.teamNames.map({ (teamName) -> Team in
            return Team(teamName: teamName, conferenceName: conferenceMO.name)
        })
        self.init(name: conferenceMO.name, conferenceOption: nil, teams: teamsInConference)
        
    }
    
    static func newConference(withName conferenceName: String) -> Conference? {
        
        let teamsByConferenceOption = TeamsByConferenceOption.shared
        guard let data = teamsByConferenceOption.data else {
            os_log("Could not unwrap teamsByConferenceOption.data in Conference.newConference(withName:).... It may have not been initialized yet.", type: .debug)
            return nil
        }
        let conferenceOption = ConferenceOptions.getEnumValueFromStringValue(conferenceStr: conferenceName)
        guard let teamNames = data[conferenceOption] else {
            os_log("Could not unwrap data[conferenceOption] in Conference.newConference(withName:)", type: .debug)
            return nil
        }
        let teams = teamNames.map { (name) -> Team in
            return Team(teamName: name, conferenceName: conferenceName)
        }
        return Conference(name: conferenceName, conferenceOption: conferenceOption, teams: teams)
        
    }
    
    static func newConference(withTeamName teamName: String) -> Conference? {
        
        let teamsByConferenceOption = TeamsByConferenceOption.shared
        guard let data = teamsByConferenceOption.data else {
            os_log("Could not unwrap teamsByConferenceOption.data in Conference.newConference(withTeam:).... It may have not been initialized yet.", type: .debug)
            return nil
        }
        let conferenceOptionsValues = data.keys
        let conferenceOptionForTeamName = conferenceOptionsValues.filter { (conferenceOption) -> Bool in
            guard let teamNamesForConferenceOption = data[conferenceOption] else {
                os_log("Could not unwrap data[conferenceOption] in Conference.newConference(withTeam:)", type: .debug)
                return false
            }
            return teamNamesForConferenceOption.contains(teamName)
        }[0]
        guard let teamNames = data[conferenceOptionForTeamName] else {
            os_log("Could not unwrap data[conferenceOption] in Conference.newConference()", type: .debug)
            return nil
        }
        let conferenceOptionForTeamNameStr = ConferenceOptions.getStringValue(conferenceOption: conferenceOptionForTeamName)
        let teams = teamNames.map { (name) -> Team in
            return Team(teamName: name, conferenceName: conferenceOptionForTeamNameStr)
        }
        return Conference(name: conferenceOptionForTeamNameStr, conferenceOption: conferenceOptionForTeamName, teams: teams)
        
    }
    
    static func name(forTeamName teamName: String) -> String? {
        
        if teamName.count == 0 {
            os_log("Team Name passed into Conference.name(forTeamName:) is an empty string.")
            return nil
        }
        let teamsByConferenceOption = TeamsByConferenceOption.shared
        guard let data = teamsByConferenceOption.data else {
            os_log("Could not unwrap teamsByConferenceOption.data in Conference.name(forTeamName:).... It may have not been initialized yet.", type: .debug)
            return nil
        }
        let conferenceOptionsValues = data.keys
        let conferenceOptionsForTeamName = conferenceOptionsValues.filter { (conferenceOption) -> Bool in
            guard let teamNamesForConferenceOption = data[conferenceOption] else {
                os_log("Could not unwrap data[conferenceOption] in Conference.name(forTeamName:)", type: .debug)
                return false
            }
            return teamNamesForConferenceOption.contains(teamName)
        }
        guard conferenceOptionsForTeamName.count > 0 else {
            os_log("TeamsByConferenceOption has no values for teamName (%s) in Conference.name(forTeamName:)", type: .debug, teamName)
            return nil
        }
        
        return ConferenceOptions.getStringValue(conferenceOption: conferenceOptionsForTeamName[0])
        
    }
    
    static func == (lhs: Conference, rhs: Conference) -> Bool {
        guard lhs.name == rhs.name else { return false }
        guard lhs.conferenceOption == rhs.conferenceOption else { return false }
        guard lhs.teams == rhs.teams else { return false }
        return true
    }
    
}
