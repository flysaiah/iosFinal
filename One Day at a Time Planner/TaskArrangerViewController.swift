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
    
    private var extrasModel: [Task] = []
    private var scheduleModel: [[Task]]?
    private var timeRanges: [(Double, Double)]?
    
    
    // Other MVC's set these to prepare this--they are expected to be set on preparation of page
    var freeTime: [(Double, Double)]? {
        didSet {
            timeRanges = createFreeTime(freeTime!)
            scheduleModel = [[Task]](count: timeRanges!.count, repeatedValue: [])
        }
    }
    
    var tasks: [Task]? {
        didSet {
            extrasModel = tasks!
        }
    }

    // MARK: IBOutlets
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var extraTasksTableView: UITableView!
    
    // MARK: Tableview delegate/datasource functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == extraTasksTableView {
            return extrasModel.count
        } else {
            return scheduleModel![section].count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == scheduleTableView {
            return timeRanges!.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == scheduleTableView {
            let start = getTime(timeRanges![section].0)
            let end = getTime(timeRanges![section].1)
            let remainingTime = getRemainingTime(forSection: section, sectionTasks: scheduleModel![section])
            return "\(start)-\(end)\n(\(remainingTime) min remaining)"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("Task Schedule Cell", forIndexPath: indexPath) as? TaskScheduleCell {
            if tableView == scheduleTableView {
                cell.task = scheduleModel![indexPath.section][indexPath.row]
            } else {
                cell.taskLabel.textColor = UIColor.whiteColor()
                cell.priorityLabel.textColor = UIColor.whiteColor()
                cell.task = extrasModel[indexPath.row]
            }
            return cell
        } else {
            // this won't happen
            return tableView.dequeueReusableCellWithIdentifier("not possible", forIndexPath: indexPath)
        }
    }
    
    // MARK: Private auxilliary functions
    
    private func createFreeTime(freeTime: [(Double, Double)]) -> [(Double, Double)] {
        // Algorithm that maps FreeTime: (<Start of free time>, <Duration of free time>) to (<Start of free time>, <End of free time>)
        if freeTime.count == 1 {
            return freeTime
        }
        var result = [(Double, Double)]()
        var currentBlock = (freeTime[0].0, freeTime[0].1)
        for tupleIndex in 1..<freeTime.count {
            if ((currentBlock.0 + currentBlock.1) == freeTime[tupleIndex].0) {
                currentBlock.1 += freeTime[tupleIndex].1
                
                if (tupleIndex == freeTime.count-1) {
                    currentBlock.1 += currentBlock.0
                    result.append(currentBlock)
                }
            } else {
                // make it a range
                currentBlock.1 += currentBlock.0
                result.append(currentBlock)
                currentBlock.0 = freeTime[tupleIndex].0
                currentBlock.1 = freeTime[tupleIndex].1
                
                if (tupleIndex == freeTime.count-1) {
                    currentBlock.1 += currentBlock.0
                    result.append(currentBlock)
                }
            }
        }
        return result
    }
    
    private func getTime(num: Double) -> String {
        // Adjusts index-based time #s to common times like 3:30, etc.
        let adjustedNum = num + 4   // We start at 4am
        let time = ((adjustedNum + 11) % 12) + 1
        let amPm = adjustedNum < 12 || adjustedNum > 23 ? " am" : " pm"
        
        if time % 1 == 0 {
            return String(Int(time)) + amPm
        }
        let hour = Int(floor(time))
        let min = Int(floor((time - floor(time)) * 60))
        
        return "\(hour):\(min)\(amPm)"
    }
    
    private func getRemainingTime(forSection section: Int, sectionTasks: [Task]) -> Int {
        // Calculates remaining time after insertion of tasks into schedule section
        let timeRange = timeRanges![section]
        var totalTime = Int((timeRange.1 - timeRange.0)*60)
        for task in sectionTasks {
            totalTime -= task.getEstimatedTime()
        }
        return totalTime
    }

    // MARK: Drag-and-drop functionality
    
    @objc private func dragFromExtrasRecognizer(gestureRecognizer: UIGestureRecognizer) {
        // First, reset backgrounds to natural state--this is necessary when we change it in state.Changed
        resetBackgrounds()
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInExtrasTable = longPress.locationInView(extraTasksTableView)
        let locationInView = longPress.locationInView(self.view)
        let indexPath = extraTasksTableView.indexPathForRowAtPoint(locationInExtrasTable)
        
        // Holds static information about our original cell location, and the "snapshot" we create of the cell to create nice "dragging" UI effect
        struct LongPressConstants {
            static var cellSnapshot: UIView? = nil
            static var initialIndexPath: NSIndexPath? = nil
        }

        switch state {
        case UIGestureRecognizerState.Began:
            // Create snapshot and hide cell
            if indexPath != nil {
                LongPressConstants.initialIndexPath = indexPath
                let cell = extraTasksTableView.cellForRowAtIndexPath(indexPath!) as! TaskScheduleCell!
                LongPressConstants.cellSnapshot = snapshotOfCell(cell)
                let center = CGPoint(x: locationInView.x, y: locationInView.y)
                LongPressConstants.cellSnapshot!.center = center
                LongPressConstants.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.view.addSubview(LongPressConstants.cellSnapshot!)
                cell.hidden = true
            }
        case UIGestureRecognizerState.Changed:
            // Update snapshot location and highlight schedule table section if hovering over
            if let snapshot = LongPressConstants.cellSnapshot {
                let center = CGPoint(x: locationInView.x, y: locationInView.y)
                snapshot.center = center
                let locationInScheduleTable = longPress.locationInView(scheduleTableView)

                if let sectionIndex = getTargetedSectionIndex(locationInScheduleTable) {
                    let header = scheduleTableView.headerViewForSection(sectionIndex)
                    header?.backgroundView?.backgroundColor = UIColor.darkGrayColor()
                }
            }
            
            
        case UIGestureRecognizerState.Ended:
            // Update cell models, remove snapshot
            let locationInScheduleTable = longPress.locationInView(scheduleTableView)
            // First check if it's hovering over table cells
            if let ip = scheduleTableView.indexPathForRowAtPoint(locationInScheduleTable) {
                // add cell to schedule model, remove it from extras model
                var tmp = scheduleModel![ip.section]
                tmp.insert(extrasModel[LongPressConstants.initialIndexPath!.row], atIndex: ip.row)
                // Only make changes if there's enough time in the block to handle the new task
                if getRemainingTime(forSection: ip.section, sectionTasks: tmp) >= 0 {
                    scheduleModel![ip.section] = tmp
                    extrasModel.removeAtIndex(LongPressConstants.initialIndexPath!.row)
                }
                // Default way to add is to drag section header
            } else if let sectionIndex = getTargetedSectionIndex(locationInScheduleTable) {
                var tmp = scheduleModel![sectionIndex]
                tmp.append(extrasModel[LongPressConstants.initialIndexPath!.row])
                // Only make changes if there's enough time in the block to handle the new task
                if getRemainingTime(forSection: sectionIndex, sectionTasks: tmp) >= 0 {
                    scheduleModel![sectionIndex] = tmp
                    extrasModel.removeAtIndex(LongPressConstants.initialIndexPath!.row)
                }
            }
            LongPressConstants.cellSnapshot?.removeFromSuperview()
            extraTasksTableView.reloadData()
            scheduleTableView.reloadData()
            LongPressConstants.initialIndexPath = nil
            LongPressConstants.cellSnapshot = nil
        default: break
        }
    }
    
    @objc private func dragFromScheduleRecognizer(gestureRecognizer: UIGestureRecognizer) {
        // First, reset backgrounds to natural state--this is necessary when we change it in state.Changed
        resetBackgrounds()
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInScheduleTable = longPress.locationInView(scheduleTableView)
        let locationInView = longPress.locationInView(self.view)
        let indexPath = scheduleTableView.indexPathForRowAtPoint(locationInScheduleTable)
        
        // Holds static information about our original cell location, and the "snapshot" we create of the cell to create nice "dragging" UI effect
        struct LongPressConstants {
            static var cellSnapshot: UIView? = nil
            static var initialIndexPath: NSIndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.Began:
            // Create snapshot and hide cell
            if indexPath != nil {
                LongPressConstants.initialIndexPath = indexPath
                let cell = scheduleTableView.cellForRowAtIndexPath(indexPath!) as! TaskScheduleCell!
                LongPressConstants.cellSnapshot = snapshotOfCell(cell)
                let center = CGPoint(x: locationInView.x, y: locationInView.y)
                LongPressConstants.cellSnapshot!.center = center
                LongPressConstants.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.view.addSubview(LongPressConstants.cellSnapshot!)
                cell.hidden = true
            }
        case UIGestureRecognizerState.Changed:
            // Update snapshot location and highlight schedule table section if hovering over
            if let snapshot = LongPressConstants.cellSnapshot {
                let center = CGPoint(x: locationInView.x, y: locationInView.y)
                snapshot.center = center
                
                if let sectionIndex = getTargetedSectionIndex(locationInScheduleTable) {
                    // Make sure this isn't the original section
                    if sectionIndex != LongPressConstants.initialIndexPath!.section {
                        let header = scheduleTableView.headerViewForSection(sectionIndex)
                        header?.backgroundView?.backgroundColor = UIColor.darkGrayColor()
                    }
                }
            }
        case UIGestureRecognizerState.Ended:
            // Update cell models, remove snapshot
            // First check if it's hovering over table cells
            if let ip = scheduleTableView.indexPathForRowAtPoint(locationInScheduleTable) {
                var tmp = scheduleModel![ip.section]
                tmp.insert(scheduleModel![LongPressConstants.initialIndexPath!.section][LongPressConstants.initialIndexPath!.row], atIndex: ip.row)
                if ip.section == LongPressConstants.initialIndexPath!.section {
                    tmp.removeAtIndex(LongPressConstants.initialIndexPath!.row + 1)
                    scheduleModel![ip.section] = tmp
                } else {
                    scheduleModel![ip.section] = tmp
                    scheduleModel![LongPressConstants.initialIndexPath!.section].removeAtIndex(LongPressConstants.initialIndexPath!.row)
                }


                // Then, check if we're inserting into another header
            } else if let sectionIndex = getTargetedSectionIndex(locationInScheduleTable) {
                // Can't re-insert into same section
                if sectionIndex != LongPressConstants.initialIndexPath!.section {
                    var tmp = scheduleModel![sectionIndex]
                    tmp.append(scheduleModel![LongPressConstants.initialIndexPath!.section][LongPressConstants.initialIndexPath!.row])
                    // Only make changes if there's enough time in the block to handle the new task
                    if getRemainingTime(forSection: sectionIndex, sectionTasks: tmp) >= 0 {
                        scheduleModel![sectionIndex] = tmp
                        scheduleModel![LongPressConstants.initialIndexPath!.section].removeAtIndex(LongPressConstants.initialIndexPath!.row)
                    }
                }
                // Default is to put it back into the extras list
            } else {
                extrasModel.append(scheduleModel![LongPressConstants.initialIndexPath!.section][LongPressConstants.initialIndexPath!.row])
                scheduleModel![LongPressConstants.initialIndexPath!.section].removeAtIndex(LongPressConstants.initialIndexPath!.row)
            }
            LongPressConstants.cellSnapshot?.removeFromSuperview()
            extraTasksTableView.reloadData()
            scheduleTableView.reloadData()
            LongPressConstants.initialIndexPath = nil
            LongPressConstants.cellSnapshot = nil
        default: break
        }

    }
    
    private func snapshotOfCell(inputView: UIView) -> UIView {
        // Creates "snapshot" of cell we're dragging--basically an image that shows the user that he/she is really dragging a cell
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
    }
    
    private func resetBackgrounds() {
        // Resets background color of each section in schedule table to natural state
        for sectionIndex in 0..<scheduleModel!.count {
            scheduleTableView.headerViewForSection(sectionIndex)!.backgroundView?.backgroundColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 0.0)
        }
    }
    
    private func getTargetedSectionIndex(location: CGPoint) -> Int? {
        // If snapshot is above one of the schedule table sections, return the section index--otherwise return nil
        for sectionIndex in 0..<scheduleModel!.count {
            if CGRectContainsPoint(scheduleTableView.headerViewForSection(sectionIndex)!.frame, location) {
                return sectionIndex
            }
        }
        return nil
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Long press to start dragging from extras table to schedule table
        let longPress1 = UILongPressGestureRecognizer(target: self, action: #selector(dragFromExtrasRecognizer))
        extraTasksTableView.addGestureRecognizer(longPress1)
        // Long press to start dragging from schedule table to either schedule table or extras table
        let longPress2 = UILongPressGestureRecognizer(target: self, action: #selector(dragFromScheduleRecognizer))
        scheduleTableView.addGestureRecognizer(longPress2)
    }
}