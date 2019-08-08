//
//  TeamStatsCardController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/27/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import RxCocoa
import CardParts
import Bond
import os.log

class TeamStatsCardController: CardPartsViewController, RoundedCardTrait, NoTopBottomMarginsCardTrait {
    
    public var allGames = [Game]()
    public var team: Team
    var viewModel: TeamStatsTableViewModel
    var titlePart = CardPartTitleView(type: .titleOnly)
    var tableViewPart = CardPartTableView()
    
    init(team: Team) {
        self.team = team
        self.viewModel = TeamStatsTableViewModel(team: self.team)
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
            
            if indexPath.row == 0 {
                cell.leftTitleLabel.text = "Record"
                cell.rightTitleLabel.text = "Probability"
                return cell
            }
            
            guard let tableDataTuples = tableData as? [(String, Double)] else {
                return UITableViewCell()
            }
            
            let recordString = tableDataTuples[indexPath.row - 1].0
            let probabilityToGetRecordTimes100 = tableDataTuples[indexPath.row].1 * 10000
            let probabilityToGetRecord = probabilityToGetRecordTimes100.rounded(.down) / 100
            cell.leftTitleLabel.text = recordString
            cell.rightTitleLabel.text = String(probabilityToGetRecord) + " %"
            
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

class TeamStatsTableViewModel {
    
    var allGames: [Game]
    var team: Team
    var teamResultsData: TeamResultsData
    var tableData = MutableObservableArray([])
    
    var title = BehaviorRelay(value: "")
    var text = BehaviorRelay(value: "")
    
    init(team: Team) {
        
        self.team = team
        let dataModelManager = DataModelManager.shared
        self.allGames = dataModelManager.getAllGames()
        
        let gamesPlayedByTeam = self.allGames.filter { (game) -> Bool in
            return game.contestants.contains(team)
        }
        self.teamResultsData = TeamResultsData(teamName: team.name, games: gamesPlayedByTeam)
        
        tableData.append((">= 8 wins", self.teamResultsData.calculateProbOfWinningAtLeast8Games()))
        for record in self.teamResultsData.possibleRecords {
            let probOfWinningXGames = self.teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: record.numberOfWins)
            tableData.append((record.recordStr, probOfWinningXGames))
        }
        
        // When these values change, the UI in the CardController
        // will automatically update
        title.accept(self.team.name)
        
    }
    
}
