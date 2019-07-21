//
//  HomeScreenViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/20/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log

class HomeScreenTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.showSpinner(onView: self.view)
        let teamsByConferenceNetworkManager = TeamsByConferenceNetworkManager()
        teamsByConferenceNetworkManager.getTeamsByConference(completion: { (data, error) in
            guard let data = data else {
                os_log("Could not unwrap teamsByConference data in LoginViewController.viewDidLoad()", type: .debug)
                self.removeSpinner()
                let _ = UIAlertAction(title: "Network unavailable", style: .cancel, handler: { (alert) in
                    alert.isEnabled = true
                })
                return
            }
            let dataModelManager = DataModelManager.shared
            DispatchQueue.main.sync {
                dataModelManager.loadTeamNamesByConference(teamNamesByConferenceName: data)
                dataModelManager.loadGamesFromCoreData()
            }
            if let _ = dataModelManager.allGames {
                self.removeSpinner()
                return
            } else {
                let gamesNetworkManager = GamesNetworkManager()
                gamesNetworkManager.getGames { (data, error) in
                    guard let data = data else {
                        os_log("Could not unwrap games data in LoginViewController.viewDidLoad()", type: .debug)
                        self.removeSpinner()
                        let _ = UIAlertAction(title: "Network unavailable", style: .cancel, handler: { (alert) in
                            alert.isEnabled = true
                        })
                        return
                    }
                    DispatchQueue.main.sync {
                        dataModelManager.loadGames(gameApiResponses: data)
                    }
                }
            }
            
        })
        self.removeSpinner()
        
    }
    
}
