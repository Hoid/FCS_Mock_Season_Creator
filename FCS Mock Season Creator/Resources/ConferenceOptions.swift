//
//  Conference.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log

enum ConferenceOptions {
    
    case all, caa, mvfc, bigsky, bigsouth, southern, southland, ivy, meac, nec, ovc, pioneer, swac, independent
    
    public static func getStringValue(conferenceOption: ConferenceOptions) -> String {
        
        switch conferenceOption {
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
    
    public static func getEnumValueFromStringValue(conferenceStr: String) -> ConferenceOptions {
        
        switch conferenceStr {
        case "All":
            return ConferenceOptions.all
        case "Big Sky":
            return ConferenceOptions.bigsky
        case "Big South":
            return ConferenceOptions.bigsouth
        case "CAA":
            return ConferenceOptions.caa
        case "Independent":
            return ConferenceOptions.independent
        case "Ivy":
            return ConferenceOptions.ivy
        case "MEAC":
            return ConferenceOptions.meac
        case "MVFC":
            return ConferenceOptions.mvfc
        case "NEC":
            return ConferenceOptions.nec
        case "OVC":
            return ConferenceOptions.ovc
        case "Pioneer":
            return ConferenceOptions.pioneer
        case "Southern":
            return ConferenceOptions.southern
        case "Southland":
            return ConferenceOptions.southland
        case "SWAC":
            return ConferenceOptions.swac
        default:
            os_log("Could not find corresponding conference for string value in Conference.swift", type: .debug)
            return ConferenceOptions.all
        }
        
    }
    
}
