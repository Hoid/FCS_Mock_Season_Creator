//
//  CoreDataMigrationVersion.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 8/21/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

enum CoreDataMigrationVersion: String, CaseIterable {
    case version1 = "FCS_Mock_Season_Creator"
    case version2 = "FCS_Mock_Season_Creator2"
    
    // MARK: - Current
    
    static var current: CoreDataMigrationVersion {
        guard let current = allCases.last else {
            fatalError("no model versions found")
        }
        
        return current
    }
    
    // MARK: - Migration
    
    func nextVersion() -> CoreDataMigrationVersion? {
        switch self {
        case .version1:
            return .version2
        case .version2:
            return nil
        }
    }
}
