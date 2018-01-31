//
//  TestTableViewController.swift
//  SliderPanel
//
//  Created by seb on 27.03.15.
//  Copyright (c) 2015 seb. All rights reserved.
//

import Foundation
import UIKit

class TestTableViewController: UITableViewController {
    
    var uiTestIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL_ID")
        
        self.tableView.accessibilityIdentifier = uiTestIdentifier
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_ID", for: indexPath as IndexPath)
        
        cell.textLabel!.text = "Test \(indexPath.row)"
        
        return cell
    }

}
