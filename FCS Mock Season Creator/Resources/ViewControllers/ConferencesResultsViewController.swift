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
import os.log

class ConferencesResultsViewController: CardsViewController {
    
    var cards: [CardController] {
        let dataModelManager = DataModelManager.shared
        let allConferences = dataModelManager.getAllConferences()

        let conferenceResultsCardControllers = allConferences.map({ ConferenceResultsCardController(conference: $0) })
        return conferenceResultsCardControllers
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCards(cards: cards)
    }
    
}
