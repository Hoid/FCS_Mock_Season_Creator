//
//  ResultsViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/11/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import RxCocoa
import CardParts

class ResultsViewController: CardsViewController {
    
    let cards: [CardController] = [OverallFCSResultsCardController()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCards(cards: cards)
    }
    
}
