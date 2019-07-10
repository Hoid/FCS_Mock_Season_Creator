//
//  ConferenceResultsTableViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log
import CoreData

class ConferenceResultsTableViewController: UITableViewController {
    
    var allGames = [Game]()
    var gamesToBeShown: [Game] {
        return allGames.filter { (game) -> Bool in
            guard let conference = self.conference else {
                os_log("conference is nil in ConferenceResultsTableViewController", log: OSLog.default, type: .debug)
                return false
            }
            let gameConferences = game.conferences.map({ Conference.getEnumValueFromStringValue(conferenceStr: $0) })
            if (self.conference == Conference.all) || (gameConferences.contains(conference)) {
                return true
            } else {
                return false
            }
        }
    }
    var conference: Conference?
    let CONFERENCE_RESULTS_CELL_IDENTIFIER = "ConferenceResultsTableViewCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadGames()
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gamesToBeShown.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CONFERENCE_RESULTS_CELL_IDENTIFIER, for: indexPath) as? ConferenceResultsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ConferenceResultsTableViewCell.")
        }
        guard let game = self.gamesToBeShown[safe: indexPath.row] else {
            os_log("Could not unwrap game for indexPath in ConferenceResultsTableViewController.swift", log: OSLog.default, type: .default)
            self.tableView.reloadData()
            return ConferenceResultsTableViewCell()
        }
        
        cell.gameWinnerControl.removeAllSegments()
        cell.gameWinnerControl.insertSegment(withTitle: game.contestants[0], at: 0, animated: true)
        cell.gameWinnerControl.insertSegment(withTitle: game.contestants[1], at: 1, animated: true)
        guard let winnerIndex = game.contestants.firstIndex(of: game.winner) else {
            os_log("Could not unwrap selectedSegmentIndex for game winner in tableView(cellForRowAt:) in ConferenceResultsTableViewController", type: .debug)
            return ConferenceResultsTableViewCell()
        }
        cell.gameWinnerControl.selectedSegmentIndex = winnerIndex
        cell.confidenceTextField.text = String(game.confidence)
        cell.confidenceAverageAllUsersLabel.text = "0"
        
        return cell
        
    }
    
    // MARK: - Private functions
    
    private func loadGames() {
        
        os_log("loadGames() called", log: OSLog.default, type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        self.allGames = [
            Game.newGame(context: managedContext, contestants: ["Elon", "JMU"], winner: "Elon", confidence: 55, conferences: [.caa]),
            Game.newGame(context: managedContext, contestants: ["Elon", "Wake Forest"], winner: "Wake Forest", confidence: 65, conferences: [.caa]),
            Game.newGame(context: managedContext, contestants: ["Elon", "The Citadel"], winner: "Elon", confidence: 60, conferences: [.caa, .southern])
        ]
        
    }
    
}
