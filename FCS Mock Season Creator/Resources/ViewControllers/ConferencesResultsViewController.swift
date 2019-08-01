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
        let allConferencesExceptNamedNone = allConferences.filter({ $0.name != "None" })
        var cardControllers = [CardController]()
        var conferenceResultsCardControllers = allConferencesExceptNamedNone.map({ ConferenceResultsCardController(conference: $0) })
        conferenceResultsCardControllers.sort(by: { $0.conference.name < $1.conference.name })
        cardControllers.append(SpacerCardController())
        conferenceResultsCardControllers.forEach({ cardControllers.append($0) })
        return cardControllers
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCards(cards: cards)
    }
    
}
