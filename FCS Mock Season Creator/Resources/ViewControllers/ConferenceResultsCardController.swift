//
//  ConferenceResultsCardController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/14/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log
import CoreData
import RxCocoa
import CardParts
import Bond

class ConferenceResultsCardController: CardPartsViewController, RoundedCardTrait, NoTopBottomMarginsCardTrait {
    
    var allGames = [Game]()
    var conference: Conference
    var viewModel: ConferenceResultsTableViewModel
    var titlePart = CardPartTitleView(type: .titleOnly)
    var tableViewPart = CardPartTableView()
    
    init(conference: Conference) {
        self.conference = conference
        self.viewModel = ConferenceResultsTableViewModel(conference: self.conference)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.allGames = viewModel.allGames
        
        viewModel.title.asObservable().bind(to: titlePart.rx.title).disposed(by: bag)
        viewModel.tableData.bind(to: tableViewPart.tableView) { tableData, indexPath, tableView in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as? CardPartTableViewCell else {
                return UITableViewCell()
            }
            
            guard let tableDataTuple = tableData as? [(Int, String, Record)] else {
                return UITableViewCell()
            }
            
            let placement = tableDataTuple[indexPath.row].0 + 1
            let teamName = tableDataTuple[indexPath.row].1
            cell.leftTitleLabel.text = "\(placement). \(teamName)"
            cell.rightTitleLabel.text = tableDataTuple[indexPath.row].2.recordStr
            
            return cell
            
        }
        
        if let uiFont = UIFont(name: "Arial", size: 22.0) {
            titlePart.titleFont = uiFont
        } else {
            os_log("Could not create UIFont in ConferenceResultsCardController.viewDidLoad()", type: .debug)
        }
        
        setupCardParts([titlePart, tableViewPart])
        
    }
    
    func cornerRadius() -> CGFloat {
        return 10.0
    }
    
    func requiresNoTopBottomMargins() -> Bool {
        return false
    }
    
}

class ConferenceResultsTableViewModel {
    
    var allGames = [Game]()
    var conference: Conference
    var tableData = MutableObservableArray([])
    
    var title = BehaviorRelay(value: "")
    var text = BehaviorRelay(value: "")
    
    init(conference: Conference) {
        
        self.conference = conference
        
        loadGames()
        
//        for teamNameByConference in TeamsByConferenceOption.data.values {
//            for teamName in teamNameByConference {
//                let gamesPlayedByTeam = self.allGames.filter({ (game) -> Bool in
//                    return game.contestants.contains(teamName)
//                })
//                allTeamResults.append(TeamResultsData(teamName: teamName, games: gamesPlayedByTeam))
//            }
//        }
        var teamResultsForConference = [TeamResultsData]()
        for team in self.conference.teams {
            let gamesPlayedByTeam = self.allGames.filter { (game) -> Bool in
                return game.contestants.contains(team.name)
            }
            teamResultsForConference.append(TeamResultsData(teamName: team.name, games: gamesPlayedByTeam))
        }
        let conferenceSeasonResult = ConferenceSeasonResult(conference: self.conference, teamResults: teamResultsForConference)
        print(conferenceSeasonResult.placementMappedToTeamAndRecord)
        
        let sortedTeamsAndRecords = conferenceSeasonResult.placementMappedToTeamAndRecord.values.enumerated()
        for (index, (teamName, record)) in sortedTeamsAndRecords {
            tableData.append((index, teamName, record))
        }
        
        // When these values change, the UI in the TestCardController
        // will automatically update
        title.accept(self.conference.name)
        
    }
    
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
}
