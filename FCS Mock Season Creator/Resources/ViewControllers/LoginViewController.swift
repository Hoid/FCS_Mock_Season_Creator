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
                let _ = DataModelManager(teamNamesByConferenceName: data)
            }
        })
            self.removeSpinner()
        
    }

}

