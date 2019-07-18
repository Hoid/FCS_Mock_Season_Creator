//
//  TeamMO.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import os.log

class TeamMO: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var conferenceName: String
    
}

extension TeamMO {
    
    public static func newTeamMO(name: String, conferenceName: String, withContext managedContext: NSManagedObjectContext) -> TeamMO? {
        
        let entity = NSEntityDescription.entity(forEntityName: "TeamMO", in: managedContext)!
        let newTeamMO = TeamMO(entity: entity, insertInto: managedContext)
        newTeamMO.name = name
        newTeamMO.conferenceName = conferenceName
        return newTeamMO
        
    }
    
    public static func newTeamMO(fromTeam team: Team, withContext managedContext: NSManagedObjectContext) -> TeamMO? {
        
        let entity = NSEntityDescription.entity(forEntityName: "TeamMO", in: managedContext)!
        let newTeamMO = TeamMO(entity: entity, insertInto: managedContext)
        newTeamMO.name = team.name
        newTeamMO.conferenceName = team.conferenceName
        return newTeamMO
        
    }
    
}
