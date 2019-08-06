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

class ConferenceGamesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameWinnerControl: UISegmentedControl!
    @IBOutlet weak var confidenceTextField: UITextField!
    
    var game: Game?
    
    public func setup(game: Game) {
        
        self.game = game
        self.confidenceTextField.keyboardType = UIKeyboardType.numberPad
        self.gameWinnerControl.removeAllSegments()
        guard let team1Name = game.contestants.first?.name, let team2Name = game.contestants.last?.name else {
            os_log("Could not unwrap team1Name in ConferenceGamesTableViewCell.setup()", type: .debug)
            return
        }
        self.gameWinnerControl.insertSegment(withTitle: team1Name, at: 0, animated: true)
        self.gameWinnerControl.insertSegment(withTitle: team2Name, at: 1, animated: true)
        self.confidenceTextField.text = String(game.confidence)
        if team1Name == game.winner.name {
            self.gameWinnerControl.selectedSegmentIndex = 0
        } else {
            self.gameWinnerControl.selectedSegmentIndex = 1
        }
        if game.confidence == 100 {
            self.confidenceTextField.isUserInteractionEnabled = false
            self.gameWinnerControl.isUserInteractionEnabled = false
        }
        
    }

}
