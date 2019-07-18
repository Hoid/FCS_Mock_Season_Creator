//
//  ViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import UIKit
import os.log

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let teamsByConferenceNetworkManager = TeamsByConferenceNetworkManager()
        self.showSpinner(onView: self.view)
        teamsByConferenceNetworkManager.getTeamsByConference(completion: { (data, error) in
            guard let data = data else {
                os_log("Could not unwrap data in LoginViewController.viewDidLoad()", type: .debug)
                self.removeSpinner()
                let _ = UIAlertAction(title: "Network unavailable", style: .cancel, handler: { (alert) in
                    alert.isEnabled = true
                })
                return
            }
            DispatchQueue.main.async {
                let dataModelManager = DataModelManager(teamNamesByConferenceName: data)
                for conferenceName in data.keys {
                    guard let teamNamesInConference = data[conferenceName] else {
                        os_log("Could not unwrap teamNamesInConference in LoginViewController.viewDidLoad()", type: .debug)
                        return
                    }
                    let teamsInConference = teamNamesInConference.map({ (teamName) -> Team in
                        return Team(teamName: teamName, conferenceName: conferenceName)
                    })
                    teamsInConference.forEach({ dataModelManager.saveOrCreateTeam(team: $0) })
                    let conference = Conference(name: conferenceName, conferenceOption: nil, teams: teamsInConference)
                    dataModelManager.saveOrCreateConference(conference: conference)
                }
            }
            
            self.removeSpinner()
        })
        
    }


}

