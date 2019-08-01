//
//  SpacerViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/31/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import CardParts
import RxCocoa

class SpacerViewController: CardsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCards(cards: [SpacerCardController()])
    }
    
}
