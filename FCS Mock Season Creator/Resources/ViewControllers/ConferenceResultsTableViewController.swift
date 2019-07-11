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
            }.sorted(by: { $0.week <= $1.week })
    }
    var conference: Conference?
    let CONFERENCE_RESULTS_CELL_IDENTIFIER = "ConferenceResultsTableViewCell"
    let numberOfWeeksInSeason = 14
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadGames()
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
        guard let winner = sender.titleForSegment(at: sender.selectedSegmentIndex) else {
            os_log("Could not unwrap game winner from UISegmentedControl in ConferenceResultsTableViewController", type: .debug)
            return
        }
        game.winner = winner
        updateOrCreateGame(game: game)
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
        updateOrCreateGame(game: game)
        
    }
    
    // MARK: - Private functions
    
    private func loadGames() {
        
        os_log("loadGames() called", log: OSLog.default, type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        
        do {
            self.allGames = try managedContext.fetch(fetchRequest)
            os_log("Loading %d games", log: OSLog.default, type: .debug, self.allGames.count)
            if self.allGames.count == 0 {
                self.allGames = [
                    Game.newGame(context: managedContext, contestants: ["Elon", "NC A&T"], winner: "Elon", confidence: 65, conferences: [.caa], week: 0),
                    Game.newGame(context: managedContext, contestants: ["JMU", "WVU"], winner: "WVU", confidence: 85, conferences: [.caa], week: 0),
                    Game.newGame(context: managedContext, contestants: ["Samford", "Youngstown State"], winner: "Samford", confidence: 75, conferences: [.mvfc], week: 0),
                    Game.newGame(context: managedContext, contestants: ["Elon", "The Citadel"], winner: "Elon", confidence: 60, conferences: [.caa, .southern], week: 1),
                    Game.newGame(context: managedContext, contestants: ["Elon", "Richmond"], winner: "Elon", confidence: 80, conferences: [.caa], week: 2)
                ]
                os_log("Needed to load games for the first time", log: OSLog.default, type: .debug)
            }
        } catch let error as NSError {
            print("Could not fetch games. \(error), \(error.userInfo)")
        }
        
    }
    
    private func updateOrCreateGame(game: Game) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "contestants = %@", game.contestants)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(game.id, forKey: "id")
            objectUpdate.setValue(game.conferences, forKeyPath: "conferences")
            objectUpdate.setValue(game.confidence, forKeyPath: "confidence")
            objectUpdate.setValue(game.contestants, forKeyPath: "contestants")
            objectUpdate.setValue(game.winner, forKeyPath: "winner")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update game to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            os_log("Could not fetch game from CoreData. Saving it as a new game.", type: .debug)
            
            let entity = NSEntityDescription.entity(forEntityName: "Game", in: managedContext)!
            let newGame = Game(entity: entity, insertInto: managedContext)
            
            newGame.setValue(game.id, forKey: "id")
            newGame.setValue(game.conferences, forKeyPath: "conferences")
            newGame.setValue(game.confidence, forKeyPath: "confidence")
            newGame.setValue(game.contestants, forKeyPath: "contestants")
            newGame.setValue(game.winner, forKeyPath: "winner")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save new game to CoreData. \(error), \(error.userInfo)")
            }
        }
        
    }
    
}
