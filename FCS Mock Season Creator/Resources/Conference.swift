//
//  Conference.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class Conference {
    
    var teams = [Team]()
    var conferenceOption: ConferenceOptions
    var name: String
    
    init(conferenceOption: ConferenceOptions) {
        self.conferenceOption = conferenceOption
        self.name = ConferenceOptions.getStringValue(conferenceOption: self.conferenceOption)
        for teamName in TeamsByConferenceOption.data[self.conferenceOption]! {
            self.teams.append(Team(teamName: teamName, conference: self))
        }
    }
    
}
