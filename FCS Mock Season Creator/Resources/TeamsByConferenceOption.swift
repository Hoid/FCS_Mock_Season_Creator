//
//  Conferences.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/12/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class TeamsByConferenceOption {
    
    static let data: [ConferenceOptions : [String]] = [
        .bigsky : ["Cal Poly", "EWU", "Idaho", "Idaho State", "Montana", "Montana State", "Northern Arizona", "Northern Colorado", "Portland State", "Sac State", "Southern Utah", "UC Davis", "Weber State"],
        .bigsouth : ["Campbell", "Charleston Southern", "Gardner-Webb", "Hampton", "Kennesaw State", "Monmouth", "North Alabama", "Presbyterian"],
        .caa : ["Albany", "Delaware", "Elon", "JMU", "Maine", "UNH", "URI", "Richmond", "Stony Brook", "Towson", "Villanova", "W&M"],
        .mvfc : ["Illinois State", "Indiana State", "Missouri State", "NDSU", "Northern Iowa", "South Dakota", "SDSU", "Southern Illinois", "Western Illinois", "Youngstown State"]
    ]
    
}
