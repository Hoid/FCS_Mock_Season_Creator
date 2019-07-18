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
        
        let dataModelManager = DataModelManager.shared
        self.allGames = dataModelManager.getAllGames()
        
        self.conference = conference
        
        var teamResultsForConference = [TeamResultsData]()
        for team in self.conference.teams {
            let gamesPlayedByTeam = self.allGames.filter { (game) -> Bool in
                return game.contestants.contains(team)
            }
            teamResultsForConference.append(TeamResultsData(teamName: team.name, games: gamesPlayedByTeam))
        }
        let conferenceSeasonResult = ConferenceSeasonResult(conference: self.conference, teamResults: teamResultsForConference)
        
        let sortedTeamsAndRecords = conferenceSeasonResult.placementMappedToTeamAndRecord.values.enumerated()
        for (index, (teamName, record)) in sortedTeamsAndRecords {
            tableData.append((index, teamName, record))
        }
        
        // When these values change, the UI in the TestCardController
        // will automatically update
        title.accept(self.conference.name)
        
    }

}
