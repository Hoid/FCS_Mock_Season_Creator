//
//  ConferenceMO.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log
import CoreData
import UIKit

class ConferenceMO: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var teamNames: [String]
    
}

extension ConferenceMO {
    
    public static func newConferenceMO(name: String, teamNames: [String]) -> ConferenceMO? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newConferenceMO = ConferenceMO(context: managedContext)
        newConferenceMO.name = name
        newConferenceMO.teamNames = teamNames
        return newConferenceMO
        
    }
    
    public static func newConferenceMO(fromConference conference: Conference) -> ConferenceMO? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newConferenceMO = ConferenceMO(context: managedContext)
        newConferenceMO.name = conference.name
        newConferenceMO.teamNames = conference.teams.map({ $0.name })
        return newConferenceMO
        
    }
    
}
