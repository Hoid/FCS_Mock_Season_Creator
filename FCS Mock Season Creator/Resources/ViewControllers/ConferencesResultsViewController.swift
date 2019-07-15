//
//  ConferencesResultsViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/14/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import RxCocoa
import CardParts

class ConferencesResultsViewController: CardsViewController {
    
    let cards: [CardController] = TeamsByConferenceOption.data.keys.map({ (conferenceOption) in
        let conference = Conference(conferenceOption: conferenceOption)
        return ConferenceResultsCardController(conference: conference)
    })
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCards(cards: cards)
    }
    
}
