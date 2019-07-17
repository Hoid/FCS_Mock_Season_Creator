//
//  OverallFCSResultsCardController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/11/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import os.log
import CoreData
import RxCocoa
import CardParts
import Bond

class OverallFCSResultsCardController: CardPartsViewController, RoundedCardTrait, NoTopBottomMarginsCardTrait {
    
    var allGames = [Game]()
    var viewModel = OverallFCSResultsTableViewModel()
    var aboveSpacerPart = CardPartSpacerView(height: 30.0)
    var titlePart = CardPartTitleView(type: .titleOnly)
    var tableViewPart = CardPartTableView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.allGames = viewModel.allGames
        
        viewModel.title.asObservable().bind(to: titlePart.rx.title).disposed(by: bag)
        viewModel.tableData.bind(to: tableViewPart.tableView) { tableData, indexPath, tableView in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as? CardPartTableViewCell else {
                return UITableViewCell()
            }
            
            guard let tableDataInfo = tableData as? [(Int, String, Record)] else {
                return UITableViewCell()
            }
            
            let placement = tableDataInfo[indexPath.row].0 + 1
            let teamName = tableDataInfo[indexPath.row].1
            cell.leftTitleLabel.text = "\(placement). \(teamName)"
            cell.rightTitleLabel.text = tableDataInfo[indexPath.row].2.recordStr
            
            return cell
            
        }
        
        tableViewPart.margins = UIEdgeInsets(top: 10.0, left: 14.0, bottom: 14.0, right: 10.0)
        
//        titlePart.backgroundColor = UIColor(rgb: 0xD3D3D3)
//        tableViewPart.backgroundColor = UIColor(rgb: 0xD3D3D3)
        if let uiFont = UIFont(name: "Arial", size: 22.0) {
            titlePart.titleFont = uiFont
        } else {
            os_log("Could not create UIFont in OverallFCSResultsCardController.viewDidLoad()", type: .debug)
        }
        
//        setupCardParts([aboveSpacerPart, titlePart, tableViewPart])
        setupCardParts([titlePart, tableViewPart])
        
    }
    
    func cornerRadius() -> CGFloat {
        return 10.0
    }
    
    func requiresNoTopBottomMargins() -> Bool {
        return false
    }
    
}

class OverallFCSResultsTableViewModel {
    
    var allGames = [Game]()
    var allTeamResults = [TeamResultsData]()
    var tableData = MutableObservableArray([])
    
    var title = BehaviorRelay(value: "")
    var text = BehaviorRelay(value: "")
    
    init() {
        
        let dataModelManager = DataModelManager.shared
        self.allGames = dataModelManager.getAllGames()
        let allConferences = dataModelManager.getAllConferences()
        
        for conference in allConferences {
            for team in conference.teams {
                let gamesPlayedByTeam = self.allGames.filter { (game) -> Bool in
                    return game.contestants.contains(team)
                }
                allTeamResults.append(TeamResultsData(teamName: team.name, games: gamesPlayedByTeam))
            }
        }
        let fcsSeasonResult = FCSSeasonResult(teamResults: allTeamResults)
        print(fcsSeasonResult.sortedTeamsAndRecords)
        for (index, (teamName, record)) in fcsSeasonResult.sortedTeamsAndRecords.enumerated() {
            tableData.append((index, teamName, record))
        }
        
        // When these values change, the UI in the TestCardController
        // will automatically update
        title.accept("Most Likely FCS Season Results")
        
    }
    
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
