//
//  ConferenceResultsTableViewCell.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import os.log

class ConferenceResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameWinnerControl: UISegmentedControl!
    @IBOutlet weak var confidenceTextField: UITextField!
    @IBOutlet weak var confidenceAverageAllUsersLabel: UILabel!

}
