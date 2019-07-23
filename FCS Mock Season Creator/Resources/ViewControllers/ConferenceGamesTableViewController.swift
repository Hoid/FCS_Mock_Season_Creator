//
//  ConferenceGamesTableViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log
import CoreData

class ConferenceGamesTableViewController: UITableViewController {
    
    var allGames = [Game]()
    var gamesToBeShown: [Game] {
        return allGames.filter { (game) -> Bool in
            guard let conferenceOption = self.conferenceOption else {
                os_log("conference is nil in ConferenceGamesTableViewController", log: OSLog.default, type: .debug)
                return false
            }
            let gameConferenceOptions = game.conferences.map({ $0.conferenceOption })
            if (self.conferenceOption == ConferenceOptions.all) || (gameConferenceOptions.contains(conferenceOption)) {
                return true
            } else {
                return false
            }
            }.sorted(by: { $0.week <= $1.week })
    }
    var conferenceOption: ConferenceOptions?
    let CONFERENCE_RESULTS_CELL_IDENTIFIER = "ConferenceResultsTableViewCell"
    let numberOfWeeksInSeason = 14
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let goToResultsButton = UIBarButtonItem(title: "Results", style: .done, target: self, action: #selector(goToResults))
        self.navigationItem.rightBarButtonItem = goToResultsButton
        let dataModelManager = DataModelManager.shared
        self.allGames = dataModelManager.getAllGames()
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfWeeksInSeason
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(format: "Week %d", section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        for game in self.gamesToBeShown {
            if game.week == (section) {
                count = count + 1
            }
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CONFERENCE_RESULTS_CELL_IDENTIFIER, for: indexPath) as? ConferenceGamesTableViewCell else {
            fatalError("The dequeued cell is not an instance of ConferenceResultsTableViewCell.")
        }
        let gamesInThisSection = self.gamesToBeShown.filter({ $0.week == indexPath.section })
        guard let game = gamesInThisSection[safe: indexPath.row] else {
            os_log("Could not unwrap game for indexPath in ConferenceGamesTableViewController.swift", log: OSLog.default, type: .default)
            self.tableView.reloadData()
            return ConferenceGamesTableViewCell()
        }
        
        cell.setup(game: game)
        
        return cell
        
    }
    
    @IBAction func winnerChanged(_ sender: UISegmentedControl) {
        let viewcell = sender.superview?.superview as? ConferenceGamesTableViewCell
        guard viewcell != nil else {
            os_log("viewcell is nil in winnerChanged in ConferenceGamesTableViewController", type: .debug)
            return
        }
        guard let game = viewcell?.game else {
            os_log("Could not unwrap game in winnerChanged in ConferenceGamesTableViewController", type: .debug)
            return
        }
        guard let winnerName = sender.titleForSegment(at: sender.selectedSegmentIndex) else {
            os_log("Could not unwrap game winner from UISegmentedControl in ConferenceGamesTableViewController", type: .debug)
            return
        }
        guard let winnerConferenceName = Conference.name(forTeamName: winnerName) else {
            os_log("Could not unwrap game winner conference name in ConferenceGamesTableViewController", type: .debug)
            return
        }
        game.winner = Team(teamName: winnerName, conferenceName: winnerConferenceName)
        
        let dataModelManager = DataModelManager.shared
        dataModelManager.saveOrCreateGameMO(withGame: game)
    }
    
    @IBAction func confidenceEditingDidEnd(_ sender: UITextField) {
    
        let viewcell = sender.superview?.superview as? ConferenceGamesTableViewCell
        guard viewcell != nil else {
            os_log("viewcell is nil in winnerChanged in ConferenceGamesTableViewController.confidenceEditingDidEnd()", type: .debug)
            return
        }
        guard let confidenceStr = sender.text else {
            os_log("Could not unwrap confidenceStr in confidenceChanged in ConferenceGamesTableViewController.confidenceFinishedChanging()", type: .debug)
            return
        }
        if confidenceStr == "" {
            os_log("confidenceStr was empty in ConferenceGamesTableViewController.confidenceEditingDidEnd()", type: .debug)
            return
        }
        guard let confidence = Int(confidenceStr) else {
            os_log("Could not unwrap confidence from confidenceStr (%s) in confidenceChanged in ConferenceGamesTableViewController.confidenceEditingDidEnd()", type: .debug, confidenceStr)
            return
        }
        if confidence < 50 || confidence > 100 {
            let alert = UIAlertController(title: "Error", message: "Confidence value must be between 50 and 100", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alert) in
                sender.text = "50"
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    @IBAction func confidenceChanged(_ sender: UITextField) {
        
        let viewcell = sender.superview?.superview as? ConferenceGamesTableViewCell
        guard viewcell != nil else {
            os_log("viewcell is nil in winnerChanged in ConferenceGamesTableViewController", type: .debug)
            return
        }
        guard let game = viewcell?.game else {
            os_log("Could not unwrap game in winnerChanged in ConferenceGamesTableViewController", type: .debug)
            return
        }
        guard let confidenceStr = sender.text else {
            os_log("Could not unwrap confidenceStr in confidenceChanged in ConferenceGamesTableViewController", type: .debug)
            return
        }
        if confidenceStr == "" {
            os_log("confidenceStr was empty in ConferenceGamesTableViewController.confidenceChanged()", type: .debug)
            return
        }
        guard let confidence = Int(confidenceStr) else {
            os_log("Could not unwrap confidence from confidenceStr (%s) in confidenceChanged in ConferenceGamesTableViewController", type: .debug, confidenceStr)
            return
        }
        if confidence < 50 || confidence > 100 {
            return
        }
        game.confidence = confidence
        
        let dataModelManager = DataModelManager.shared
        dataModelManager.saveOrCreateGameMO(withGame: game)
        
    }
    
    @objc func goToResults() {
        
        print("goToResults() called")
        
    }
    
}
