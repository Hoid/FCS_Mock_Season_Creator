//
//  Conference.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

enum Conference {
    
    case all, caa, mvfc, bigsky, bigsouth, southern, southland, ivy, meac, nec, ovc, pioneer, swac, independent
    
    public static func getStringValue(conference: Conference) -> String {
        
        switch conference {
        case .all:
            return "All"
        case .bigsky:
            return "Big Sky"
        case .bigsouth:
            return "Big South"
        case .caa:
            return "CAA"
        case .independent:
            return "Independent"
        case .ivy:
            return "Ivy"
        case .meac:
            return "MEAC"
        case .mvfc:
            return "MVFC"
        case .nec:
            return "NEC"
        case .ovc:
            return "OVC"
        case .pioneer:
            return "Pioneer"
        case .southern:
            return "Southern"
        case .southland:
            return "Southland"
        case .swac:
            return "SWAC"
        }
        
    }
    
    public static func getEnumValueFromStringValue(conferenceStr: String) -> Conference {
        
        switch conferenceStr {
        case "All":
            return Conference.all
        case "Big Sky":
            return Conference.bigsky
        case "Big South":
            return Conference.bigsouth
        case "CAA":
            return Conference.caa
        case "Independent":
            return Conference.independent
        case "Ivy":
            return Conference.ivy
        case "MEAC":
            return Conference.meac
        case "MVFC":
            return Conference.mvfc
        case "NEC":
            return Conference.nec
        case "OVC":
            return Conference.ovc
        case "Pioneer":
            return Conference.pioneer
        case "Southern":
            return Conference.southern
        case "Southland":
            return Conference.southland
        case "SWAC":
            return Conference.swac
        default:
            os_log("Could not find corresponding conference for string value in Conference.swift", type: .debug)
            return Conference.all
        }
        
    }
    
}
