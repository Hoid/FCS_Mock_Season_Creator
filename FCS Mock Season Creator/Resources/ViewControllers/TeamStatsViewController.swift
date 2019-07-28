//
//  TeamStatsViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/27/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import RxCocoa
import CardParts

class TeamStatsViewController: CardsViewController {
    
    var team: Team?
    var cards: [CardController] {
        guard let team = self.team else {
            let team = Team(teamName: "None", conferenceName: "None")
            return [TeamStatsCardController(team: team)]
        }
        return [TeamStatsCardController(team: team)]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCards(cards: cards)
    }
    
}
