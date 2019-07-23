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
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
        let teamsByConferenceNetworkManager = TeamsByConferenceNetworkManager()
        teamsByConferenceNetworkManager.getTeamsByConference(completion: { (data, error) in
            guard let data = data else {
                os_log("Could not unwrap teamsByConference data in LoginViewController.viewDidLoad()", type: .debug)
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    let alert = UIAlertController(title: "Network unavailable", message: "Please check your network connection, close the app, and reopen", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            let dataModelManager = DataModelManager.shared
            DispatchQueue.main.sync {
                dataModelManager.loadTeamNamesByConference(teamNamesByConferenceName: data)
                dataModelManager.loadGamesFromCoreData()
            }
            if let _ = dataModelManager.allGames {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
                return
            } else {
                let gamesNetworkManager = GamesNetworkManager()
                gamesNetworkManager.getGames { (data, error) in
                    guard let data = data else {
                        os_log("Could not unwrap games data in LoginViewController.viewDidLoad()", type: .debug)
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                        }
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
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
        
    }
    
}
