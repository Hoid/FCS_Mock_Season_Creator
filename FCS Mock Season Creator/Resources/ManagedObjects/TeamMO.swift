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
    
    public static func newTeamMO(name: String, conferenceName: String) -> TeamMO? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("Could not get appDelegate in TeamMO.newTeamMO()", type: .default)
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newTeamMO = TeamMO(context: managedContext)
        newTeamMO.name = name
        newTeamMO.conferenceName = conferenceName
        return newTeamMO
        
    }
    
    public static func newTeamMO(fromTeam team: Team) -> TeamMO? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("Could not get appDelegate in TeamMO.newTeamMO()", type: .default)
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newTeamMO = TeamMO(context: managedContext)
        newTeamMO.name = team.name
        newTeamMO.conferenceName = team.conferenceName
        return newTeamMO
        
    }
    
}
