//
//  TaskArrangerViewController.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 5/5/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

class TaskArrangerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Model + private data
    
    
    
    private var model = todoInfo(tasks: [], freeTime: [])
    private struct ta {
        var numberOfBlocks: Int
        var numberOfItems: Int
    }
    
    private var temp = ta(numberOfBlocks: 2, numberOfItems: 3)
    
    var tasks: [Task]? {
        didSet {
            model.tasks = tasks!
        }
    }
    
    var freeTime: [(Double, Double)]? {
        didSet {
            model.freeTime = freeTime!
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var extraTasksTableView: UITableView!
    // MARK: Tableview delegate/datasource functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temp.numberOfItems
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return temp.numberOfBlocks
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section!!"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("Task Schedule Cell", forIndexPath: indexPath) as? TaskScheduleCell {
            cell.textLabel?.text = "Howdy ho"
            return cell
        } else {
            // this won't happen
            return tableView.dequeueReusableCellWithIdentifier("not possible", forIndexPath: indexPath)
        }
    }
}
