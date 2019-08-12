//
//  TeamStatsViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/27/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log

class StatsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var allTeams: [Team]?
    var tableData: [String] {
        guard let teams = allTeams else {
            return []
        }
        let teamNamesWithoutConferenceNone = teams.filter({ $0.conferenceName != "None" })
        let teamNames = teamNamesWithoutConferenceNone.map({ $0.name })
        return teamNames.sorted(by: { $0 < $1 })
    }
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    override func viewWillAppear(_ animated: Bool) {
        self.automaticallyAdjustsScrollViewInsets = false
        self.definesPresentationContext = true
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        
        let dataModelManager = DataModelManager.shared
        self.allTeams = dataModelManager.getAllTeams()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = UISearchBar.Style.minimal
            
            if #available(iOS 11.0, *) {
                // For iOS 11 and later, place the search bar in the navigation bar.
                navigationItem.searchController = controller
                
                // Make the search bar always visible.
                navigationItem.hidesSearchBarWhenScrolling = false
            } else {
                // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
                tableView.tableHeaderView = controller.searchBar
            }
            
            return controller
        })()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return tableData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as? StatsTableViewCell else {
            fatalError("The dequeued cell is not an instance of StatsTableViewCell.")
        }
        if (resultSearchController.isActive) {
            cell.teamNameLabel.text = filteredTableData[indexPath.row]
            return cell
        }
        else {
            cell.teamNameLabel.text = tableData[indexPath.row]
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTeamStatsSegue" {
            guard let sender = sender as? StatsTableViewCell else {
                os_log("Could not unwrap sender as StatsTableViewCell in prepare(for segue:) in StatsViewController", type: .debug)
                return
            }
            guard let teamName = sender.teamNameLabel.text else {
                os_log("Could not unwrap teamName from teamNameLabel in prepare(for segue:) in StatsViewController", type: .debug)
                return
            }
            guard let destinationVC = segue.destination as? TeamStatsViewController else {
                os_log("Could not unwrap segue.destination in StatsViewController", type: .debug)
                return
            }
            guard let conferenceName = Conference.name(forTeamName: teamName) else {
                os_log("Could not unwrap conferenceName in prepare(for segue:) in StatsViewController", type: .debug)
                return
            }
            destinationVC.team = Team(teamName: teamName, conferenceName: conferenceName)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", searchController.searchBar.text!)
        let array = (tableData as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
}
