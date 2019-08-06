//
//  Team.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class Team: Equatable, CustomStringConvertible {
    
    var name: String
    var conferenceName: String
    
    init(teamName: String, conferenceName: String) {
        
        self.name = teamName
        self.conferenceName = conferenceName
        
    }
    
    convenience init?(fromTeamMO teamMO: TeamMO) {
        
        self.init(teamName: teamMO.name, conferenceName: teamMO.conferenceName)
        
    }
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        guard lhs.name == rhs.name else { return false }
        guard lhs.conferenceName == rhs.conferenceName else { return false }
        return true
    }
    
    var description: String {
        
        return "Team(Name: \(self.name), Conference: \(self.conferenceName)"
        
    }
    
}
