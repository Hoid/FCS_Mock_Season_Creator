//
//  ConferenceResultsTableViewCell.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log

class ConferenceResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameWinnerControl: UISegmentedControl!
    @IBOutlet weak var confidenceTextField: UITextField!
    @IBOutlet weak var confidenceAverageAllUsersLabel: UILabel!
    
    var game: Game?
    
    public func setup(game: Game) {
        
        self.game = game
        self.gameWinnerControl.removeAllSegments()
        self.gameWinnerControl.insertSegment(withTitle: game.contestants[0], at: 0, animated: true)
        self.gameWinnerControl.insertSegment(withTitle: game.contestants[1], at: 1, animated: true)
        self.confidenceTextField.text = String(game.confidence)
        self.confidenceAverageAllUsersLabel.text = "0"
        guard let winnerIndex = game.contestants.firstIndex(of: game.winner) else {
            os_log("Could not unwrap selectedSegmentIndex for game winner in ConferenceResultsTableViewCell", type: .debug)
            return
        }
        self.gameWinnerControl.selectedSegmentIndex = winnerIndex
        
    }

}
