//
//  OverallFCSResultsCardController.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/11/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import RxCocoa
import CardParts
import Bond

class OverallFCSResultsCardController: CardPartsViewController {
    
    var viewModel = TestViewModel()
    var titlePart = CardPartTitleView(type: .titleOnly)
    var tableViewPart = CardPartTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.title.asObservable().bind(to: titlePart.rx.title).disposed(by: bag)
        
        viewModel.listData.bind(to: tableViewPart.tableView) { listData, indexPath, tableView in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as? CardPartTableViewCell else {
                return UITableViewCell()
            }
            
            cell.leftTitleLabel.text = listData[indexPath.row]
            
            return cell
            
        }
        
        setupCardParts([titlePart, tableViewPart])
    }
    
}

class TestViewModel {
    
    var listData = MutableObservableArray(["item 1", "item 2", "item 3", "item 4"])
    
    var title = BehaviorRelay(value: "")
    var text = BehaviorRelay(value: "")
    
    init() {
        
        // When these values change, the UI in the TestCardController
        // will automatically update
        title.accept("Hello, world!")
        text.accept("CardParts is awesome!")
    }
}
