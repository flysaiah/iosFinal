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
    
    private var cells = [(Bool, Bool, Bool, Bool)](count: 24, repeatedValue: (false, false, false, false))
    
    private var model = todoInfo(tasks: [], freeTime: [])
    
    // This will be set when task builder returns with updated task array
    var tasks: [Task]? {
        didSet {
            model.tasks = tasks!
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(segueToTaskArranger))
            updateUI()
        }
    }
    
    // MARK: TableView constructors
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("\(indexPath.row)", forIndexPath: indexPath) as! TimeSelectionTVCell
        let time = getTimeFromRow(indexPath.row)
        //cell.timeLabel.text = time.1
        //cell.timeLabel.textColor = UIColor.blueColor();
        cell.textLabel?.text = time.1
        cell.hour = time.0
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
                cells[indexPath.row] = cell.getSelectionStatus()
                //self.tableView.reloadData()
            }
        }
    }
    
    private func updateUI() {
        // pre-select cells
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

extension NSCoder {
    class func empty() -> NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.finishEncoding()
        return NSKeyedUnarchiver(forReadingWithData: data)
    }
}
