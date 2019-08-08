//
//  HomeScreenViewController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/20/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog
import os.log

class HomeScreenTableViewController: UITableViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var gamesTableViewCell: UITableViewCell!
    @IBOutlet weak var resultsTableViewCell: UITableViewCell!
    @IBOutlet weak var statsTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        pause()
        getTeamsByConferenceAndGamesFromApi()
        
    }
    
    fileprivate func getTeamsByConferenceAndGamesFromApi() {
        let teamsByConferenceNetworkManager = TeamsByConferenceNetworkManager()
        teamsByConferenceNetworkManager.getTeamsByConference(completion: { (data, error) in
            guard let data = data else {
                os_log("Could not unwrap teamsByConference data in HomeScreenViewController.getTeamsByConferenceAndGamesFromApi()", type: .debug)
                self.resume()
                DispatchQueue.main.async {
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
            self.getGamesFromApi(dataModelManager: dataModelManager)
        })
    }
    
    fileprivate func getGamesFromApi(dataModelManager: DataModelManager) {
        let gamesNetworkManager = GamesNetworkManager()
        gamesNetworkManager.getGamesNew { (data, error) in
            guard let data = data else {
                os_log("Could not unwrap games data in HomeScreenViewController.getGamesFromApi()", type: .debug)
                self.resume()
                let alert = UIAlertController(title: "Network unavailable", message: "The API isn't available right now.", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                return
            }
            DispatchQueue.main.sync {
                dataModelManager.loadGames(gameNewApiResponses: data)
            }
            self.resume()
        }
    }
    
    @objc func infoButtonTapped() {
        
        let title = "About FCS Mock Season Creator"
        let message = "Welcome! This app allows you to make predictions about all FCS football games in the current season or just in one conference and then see the most likely results for your predictions. You can not only make predictions about who will win each game, but also how confident you are in that result! If you are very certain (perhaps 95% confident) one team will win some game, but only 55% confident they will win a different game, the first game will count more towards the likelihood of a win than the second game. The app will get better at predicting the end of season results as the season goes on, with the winners of each game being updated automatically by the API and confidences for each game already played set to 100%. As a result, you can take note of your predictions before the season starts, and see how accurate you were as the season goes on!\n\nThe FCS Mock Season Creator uses statistical binomial theorem on the backend to predict the likelihood of a team going a certain record given the number of games they play (n) and the number of wins (k). The application calculates the probability of each possible record and then presents the most likely record in the Results page. The Stats page shows the likelihood of each individual record for each team.\n\nIf you have any comments, questions about how the app works, or suggestions please leave a review on the App Store or email the developer directly at fcsmockseasoncreator@gmail.com, and thanks!"
        let popup = PopupDialog(title: title, message: message, image: nil)
        let vc = popup.viewController as! PopupDialogDefaultViewController
        vc.messageTextAlignment = NSTextAlignment.left
        let buttonOne = CancelButton(title: "Okay", dismissOnTap: true, action: nil)
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToHomeVC(segue: UIStoryboardSegue) {
        if segue.identifier == "ResultsButtonUnwindSegue" {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowResultsSegue", sender: self)
            }
        }
    }
    
    private func pause() {
        
        DispatchQueue.main.async {
            self.gamesTableViewCell.isUserInteractionEnabled = false
            self.resultsTableViewCell.isUserInteractionEnabled = false
            self.statsTableViewCell.isUserInteractionEnabled = false
            self.spinner.startAnimating()
        }
        
    }
    
    private func resume() {
        
        DispatchQueue.main.async {
            self.gamesTableViewCell.isUserInteractionEnabled = true
            self.resultsTableViewCell.isUserInteractionEnabled = true
            self.statsTableViewCell.isUserInteractionEnabled = true
            self.spinner.stopAnimating()
        }
        
    }
    
}
