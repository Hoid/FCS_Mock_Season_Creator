//
//  Team.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class Team {
    
    var name: String
    var conference: Conference
    
    init(teamName: String, conference: Conference) {
        self.name = teamName
        self.conference = conference
    }
    
}
