//
//  ConferencesTableViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log

class ConferencesTableViewController: UITableViewController {
    
    var conferences = [String]()
    var conferenceSelected: Conference?
    let CONFERENCE_CELL_IDENTIFIER = "ConferencesTableViewCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false;
        self.tableView.allowsSelection = true;
        self.view = tableView;
        
        populateConferences()
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conferences.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CONFERENCE_CELL_IDENTIFIER, for: indexPath) as? ConferencesTableViewCell else {
            fatalError("The dequeued cell is not an instance of ConferencesTableViewCell.")
        }
        guard let conference = self.conferences[safe: indexPath.row] else {
            os_log("Could not unwrap conference name for indexPath in ConferencesTableViewController.swift", log: OSLog.default, type: .default)
            self.tableView.reloadData()
            return ConferencesTableViewCell()
        }
        
        cell.conferenceLabel.text = conference
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        os_log("tableView(didSelectRowAtIndexPath:) called in ConferencesTableViewController", log: OSLog.default, type: .debug)
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! ConferencesTableViewCell
        
        guard let conferenceStr = currentCell.conferenceLabel.text else {
            os_log("Could not unwrap conferenceStr in tableView(didSelectRowAtIndexPath:) in ConferencesTableViewController", log: OSLog.default, type: .debug)
            return
        }
        self.conferenceSelected = Conference.getEnumValueFromStringValue(conferenceStr: conferenceStr)
        performSegue(withIdentifier: "showConferenceResultsSeque", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showConferenceResultsSeque" {
            let vc = segue.destination as? ConferenceResultsTableViewController
            guard let conferenceSelected = self.conferenceSelected else {
                os_log("Could not unwrap conferenceSelected in prepare(for:sender:) in ConferencesTableViewController", log: OSLog.default, type: .debug)
                return
            }
            os_log("conferenceSelected is %s", log: OSLog.default, type: .debug, Conference.getStringValue(conference: conferenceSelected))
            vc?.conference = self.conferenceSelected
        }
        
    }
    
    // MARK: - Private functions
    
    private func populateConferences() {
        os_log("Populating conferences...", log: OSLog.default, type: .debug)
        conferences = [String]()
        conferences.append(Conference.getStringValue(conference: Conference.all))
        conferences.append(Conference.getStringValue(conference: Conference.bigsky))
        conferences.append(Conference.getStringValue(conference: Conference.bigsouth))
        conferences.append(Conference.getStringValue(conference: Conference.caa))
        conferences.append(Conference.getStringValue(conference: Conference.independent))
        conferences.append(Conference.getStringValue(conference: Conference.ivy))
        conferences.append(Conference.getStringValue(conference: Conference.meac))
        conferences.append(Conference.getStringValue(conference: Conference.mvfc))
        conferences.append(Conference.getStringValue(conference: Conference.nec))
        conferences.append(Conference.getStringValue(conference: Conference.ovc))
        conferences.append(Conference.getStringValue(conference: Conference.pioneer))
        conferences.append(Conference.getStringValue(conference: Conference.southern))
        conferences.append(Conference.getStringValue(conference: Conference.southland))
        conferences.append(Conference.getStringValue(conference: Conference.swac))
    }
    
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
