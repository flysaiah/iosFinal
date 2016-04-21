//
//  TimeSelectionTVController.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/14/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

class TimeSelectionTVController: UITableViewController {
    
    private var cellArray = [Bool](count: 24, repeatedValue: false)   // true means the given index is currently selected
    
    private struct tsModel {
        var tasks: [Task]
        var freeTime: [(Int, Int)]
    }
    
    private var model = tsModel(tasks: [], freeTime: [])
    
    // MARK: TableView constructors
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Time Selection Cell", forIndexPath: indexPath) as! TimeSelectionTVCell
        cell.timeLabel.text = getRowText(indexPath.row)
        cell.timeLabel.textColor = UIColor.blueColor();
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        cellArray[indexPath.row] = true
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        cellArray[indexPath.row] = false
    }
    
    // MARK: Private auxilliary functions
    
    private func getRowText(rowNum: Int) -> String {
        // Takes the numbers 0-23 and converts them to 4am-3am
        
        let adjustedNum = rowNum + 4   // We start at 4am
        let time = ((adjustedNum + 11) % 12) + 1
        let amPm = adjustedNum < 12 || adjustedNum > 23 ? " am" : " pm"
        
        return String(time) + amPm
    }
    
    private func updateFreeTime() {
        var freeTime: [(Int, Int)] = []
        freeTime.append((1,2))
        model.freeTime = freeTime
    }
    
    // MARK: Navigation
    
    @IBAction func returnFromTaskBuilder(segue: UIStoryboardSegue) {
        if let dataSource = segue.sourceViewController as? TaskBuilderViewController {
            model.tasks = dataSource.getTasks()
        }
    }
    
    
}
