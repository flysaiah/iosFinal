//
//  TimeSelectionTVController.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/14/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

class TimeSelectionTVController: UITableViewController {
    
    // MARK: Private data + model
    
    private var cellDataArray = [[Bool]](count: 24, repeatedValue: [Bool](count: TimeSelectionTVCell.Constants.numberOfButtons+1, repeatedValue: false))
    
    private var model = todoInfo(tasks: [], freeTime: [])
    
    // This will be set when task builder returns with updated task array
    var tasks: [Task]? {
        didSet {
            model.tasks = tasks!
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(segueToTaskArranger))
            //updateUI()
        }
    }
    
    var freeTime: [(Double, Double)]? {  // temporary until user defaults storage is working
        didSet {
            model.freeTime = freeTime!
            createCellArrayFromFreeTime()
            updateUI()
        }
    }
        
    // MARK: TableView constructors
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TimeSelectionTVCell {
            cell.updateTimeModel()
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TimeSelectionTVCell {
            cell.updateTimeModel()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("\(indexPath.row)", forIndexPath: indexPath) as! TimeSelectionTVCell
        let time = getTimeFromRow(indexPath.row)
        cell.textLabel?.text = time.1
        cell.hour = time.0
        cell.selectedData = cellDataArray[indexPath.row]
        // we need to do selection here because it doesn't behave right when done in the cell
        if cellDataArray[indexPath.row][0] == true {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
        return cell
    }
    
    // MARK: Private functions
    
    private func getTimeFromRow(rowNum: Int) -> (Int, String) {
        // Takes the numbers 0-23 and converts them to 4am-3am
        
        let adjustedNum = rowNum + 4   // We start at 4am
        let time = ((adjustedNum + 11) % 12) + 1
        let amPm = adjustedNum < 12 || adjustedNum > 23 ? " am" : " pm"
        
        return (time, String(time) + amPm)
    }
    
    @objc private func updateFreeTime(notification: NSNotification) {
        if let cell = notification.object as? TimeSelectionTVCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                cellDataArray[indexPath.row] = cell.getSelectionStatus()
            }
        }
    }
    
    private func updateUI() {
        self.tableView.reloadData()
    }
    
    private func calculateFreeTimeFromCellArray() {
        // updates freeTime based on data from each cell
        // First, reset free time
        model.freeTime = []
        for index in 0..<cellDataArray.count {
            let hour = Double(index)   // For readability
            // easy case
            if cellDataArray[index][0] == true {
                model.freeTime.append((hour, 1.0))
            } else {
                // more complicated case
                let cellData = cellDataArray[index]
                var startOfChain = -1
                for boolIndex in 0..<cellData.count {
                    if cellData[boolIndex] == true {
                        if startOfChain == -1 { startOfChain = boolIndex }
                        if boolIndex == cellData.count-1 || cellData[boolIndex+1] == false {
                            // end of chain--log freeTime
                            let hourStart = hour + Double(startOfChain - 1) / Double(TimeSelectionTVCell.Constants.numberOfButtons)
                            let rangeMultiplier = Double(boolIndex - startOfChain + 1)
                            let totalTime = rangeMultiplier / Double(TimeSelectionTVCell.Constants.numberOfButtons)
                            model.freeTime.append(hourStart, totalTime)
                            startOfChain = -1
                        }
                    }
                }
            }
        }
    }
    
    private func createCellArrayFromFreeTime() {
        // reverse of calculateFreeTimeFromCellArray
        for tuple in model.freeTime {
            if tuple.1 == 1.0 {
                cellDataArray[Int(tuple.0)][0] = true
            } else {
                let smallestIncrement = 1.0 / Double(TimeSelectionTVCell.Constants.numberOfButtons)
                let numberOfCells = Int(floor(tuple.1 / smallestIncrement))
                
                for i in 1...numberOfCells {
                    let fractionalIndex = Int((tuple.0 - floor(tuple.0)) * Double(TimeSelectionTVCell.Constants.numberOfButtons)) + i
                    let hourIndex = Int(floor(tuple.0))
                    cellDataArray[hourIndex][fractionalIndex] = true
                }
            }
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFreeTime), name: "TimeSelectionCellModelUpdate", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "TimeSelectionCellModelUpdate", object: nil)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        calculateFreeTimeFromCellArray()
        if let identifier = segue.identifier {
            switch identifier {
                case "Show Task Builder":
                    if let nav = segue.destinationViewController as? UINavigationController {
                        if let tb = nav.topViewController as? TaskBuilderViewController {
                            tb.freeTime = model.freeTime
                        }
                    }
                case "Show Task Arranger":
                    print("WOOO!!!")
            default: break
            }
        }
    }
    
    @objc private func segueToTaskArranger() {
        self.performSegueWithIdentifier("Show Task Arranger", sender: self.navigationItem.rightBarButtonItem)
    }
}
