//
//  Team.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class Team {
    
    var teamName: String
    var conference: Conference
    
    init(teamName: String, conference: Conference) {
        self.teamName = teamName
        self.conference = conference
    }
    
}
