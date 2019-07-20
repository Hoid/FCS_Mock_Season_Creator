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
            DispatchQueue.main.sync {
                let dataModelManager = DataModelManager.shared
                dataModelManager.loadTeamNamesByConference(teamNamesByConferenceName: data)
            }
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
                    let dataModelManager = DataModelManager.shared
                    dataModelManager.loadGames(gameApiResponses: data)
                }
            }
        })
        self.removeSpinner()
        
    }

}

