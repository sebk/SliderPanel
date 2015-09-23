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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CELL_ID")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell

        if(cell == nil) {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        
        cell!.textLabel!.text = "Test \(indexPath.row)"
        
        return cell!
*/
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL_ID", forIndexPath: indexPath)
        
        cell.textLabel!.text = "Test \(indexPath.row)"
        
        return cell
        
    }

}