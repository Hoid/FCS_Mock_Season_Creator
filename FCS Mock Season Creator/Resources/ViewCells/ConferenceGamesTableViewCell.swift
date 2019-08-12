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
            os_log("Could not unwrap team1Name or team2namein ConferenceGamesTableViewCell.setup()", type: .debug)
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
            print("Game with contestants (\(team1Name), \(team2Name)) has the winner set to \(game.winner.name)")
            self.confidenceTextField.isUserInteractionEnabled = false
            self.gameWinnerControl.isUserInteractionEnabled = false
            self.backgroundColor = UIColor.init(red: 224, green: 224, blue: 224)
        } else {
            self.confidenceTextField.isUserInteractionEnabled = true
            self.gameWinnerControl.isUserInteractionEnabled = true
            self.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        }
        
    }

}
