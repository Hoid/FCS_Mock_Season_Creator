//
//  SpacerCardController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/31/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import CardParts
import RxCocoa

class SpacerCardController: CardPartsViewController, NoTopBottomMarginsCardTrait, TransparentCardTrait {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCardParts([CardPartSpacerView(height: 6)])
        
    }
    
    func requiresNoTopBottomMargins() -> Bool {
        return true
    }
    
}
