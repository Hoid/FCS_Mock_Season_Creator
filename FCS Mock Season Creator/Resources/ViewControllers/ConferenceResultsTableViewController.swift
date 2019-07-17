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
            guard let conferenceOption = self.conferenceOption else {
                os_log("conference is nil in ConferenceResultsTableViewController", log: OSLog.default, type: .debug)
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
        return String.init(format: "Week %d", section)
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CONFERENCE_RESULTS_CELL_IDENTIFIER, for: indexPath) as? ConferenceResultsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ConferenceResultsTableViewCell.")
        }
        let gamesInThisSection = self.gamesToBeShown.filter({ $0.week == indexPath.section })
        guard let game = gamesInThisSection[safe: indexPath.row] else {
            os_log("Could not unwrap game for indexPath in ConferenceResultsTableViewController.swift", log: OSLog.default, type: .default)
            self.tableView.reloadData()
            return ConferenceResultsTableViewCell()
        }
        
        cell.setup(game: game)
        
        return cell
        
    }
    
    @IBAction func winnerChanged(_ sender: UISegmentedControl) {
        os_log("Saving game because winner was changed", type: .debug)
        let viewcell = sender.superview?.superview as? ConferenceResultsTableViewCell
        guard viewcell != nil else {
            os_log("viewcell is nil in winnerChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        guard let game = viewcell?.game else {
            os_log("Could not unwrap game in winnerChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        guard let winnerName = sender.titleForSegment(at: sender.selectedSegmentIndex) else {
            os_log("Could not unwrap game winner from UISegmentedControl in ConferenceResultsTableViewController", type: .debug)
            return
        }
        guard let winnerConferenceName = Conference.name(forTeamName: winnerName) else {
            os_log("Could not unwrap game winner conference name in ConferenceResultsTableViewController", type: .debug)
            return
        }
        game.winner = Team(teamName: winnerName, conferenceName: winnerConferenceName)
        guard let gameMO = GameMO.newGameMO(fromGame: game) else {
            os_log("Could not unwrap gameMO from game in ConferenceResultsTableViewController", type: .debug)
            return
        }
        
        let dataModelManager = DataModelManager.shared
        dataModelManager.saveOrCreateGameMO(gameMO: gameMO)
    }
    
    @IBAction func confidenceChanged(_ sender: UITextField) {
        
        os_log("Saving game because confidence was changed", type: .debug)
        let viewcell = sender.superview?.superview as? ConferenceResultsTableViewCell
        guard viewcell != nil else {
            os_log("viewcell is nil in winnerChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        guard let game = viewcell?.game else {
            os_log("Could not unwrap game in winnerChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        guard let confidenceStr = sender.text else {
            os_log("Could not unwrap confidenceStr in confidenceChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        guard let confidence = Int(confidenceStr) else {
            os_log("Could not unwrap confidence from confidenceStr in confidenceChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        game.confidence = confidence
        guard let gameMO = GameMO.newGameMO(fromGame: game) else {
            os_log("Could not unwrap gameMO in confidenceChanged in ConferenceResultsTableViewController", type: .debug)
            return
        }
        
        let dataModelManager = DataModelManager.shared
        dataModelManager.saveOrCreateGameMO(gameMO: gameMO)
        
    }
    
    @objc func goToResults() {
        
        print("goToResults() called")
        
    }
    
}
