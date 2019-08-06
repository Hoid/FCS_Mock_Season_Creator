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
    var conferenceSelected: ConferenceOptions?
    let CONFERENCE_CELL_IDENTIFIER = "ConferencesTableViewCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
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
        
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! ConferencesTableViewCell
        
        guard let conferenceStr = currentCell.conferenceLabel.text else {
            os_log("Could not unwrap conferenceStr in tableView(didSelectRowAtIndexPath:) in ConferencesTableViewController", log: OSLog.default, type: .debug)
            return
        }
        self.conferenceSelected = ConferenceOptions.getEnumValueFromStringValue(conferenceStr: conferenceStr)
        performSegue(withIdentifier: "showConferenceResultsSeque", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showConferenceResultsSeque" {
            let vc = segue.destination as? ConferenceGamesTableViewController
            guard self.conferenceSelected != nil else {
                os_log("Could not unwrap conferenceSelected in prepare(for:sender:) in ConferencesTableViewController", log: OSLog.default, type: .debug)
                return
            }
            vc?.conferenceOption = self.conferenceSelected
        }
        
    }
    
    // MARK: - Private functions
    
    private func setupView() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false
        self.tableView.allowsSelection = true
        self.view = tableView
                
    }
    
    private func populateConferences() {
        conferences = [String]()
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.all))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.bigsky))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.bigsouth))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.caa))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.independent))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.ivy))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.meac))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.mvfc))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.nec))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.ovc))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.pioneer))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.southern))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.southland))
        conferences.append(ConferenceOptions.getStringValue(conferenceOption: ConferenceOptions.swac))
    }
    
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
