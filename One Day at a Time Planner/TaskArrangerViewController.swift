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
    
    var scheduleModel = [1, 2, 3]
    var extrasModel = [1,2,3]
    
    // MARK: IBOutlets
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var extraTasksTableView: UITableView!
    // MARK: Tableview delegate/datasource functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == extraTasksTableView {
            return extrasModel.count
        } else {
            return scheduleModel.count
        }
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
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Long press to start dragging
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognizer))
        extraTasksTableView.addGestureRecognizer(longPress)
    }
    
    @objc private func longPressRecognizer(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInTable = longPress.locationInView(extraTasksTableView)
        let locationInView = longPress.locationInView(self.view)
        let indexPath = extraTasksTableView.indexPathForRowAtPoint(locationInTable)
        
        struct My {
            static var cellSnapshot: UIView? = nil
        }
        
        struct Path {
            static var initialIndexPath: NSIndexPath? = nil
        }
        
        
        switch state {
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = extraTasksTableView.cellForRowAtIndexPath(indexPath!) as! TaskScheduleCell!
                My.cellSnapshot = snapshotOfCell(cell)
                var center = cell.center
                My.cellSnapshot!.center = center
                //My.cellSnapshot!.alpha = 0.0
                self.view.addSubview(My.cellSnapshot!)
                UIView.animateWithDuration(0.0, animations: { () in
                    center.y = locationInView.y
                    center.x = locationInView.x
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    //My.cellSnapshot!.alpha = 0.0
                    }, completion: { (finished) in
                        if finished {
                            cell.hidden = true
                        }
                })
            }
        case UIGestureRecognizerState.Changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            center.x = locationInView.x
            
            My.cellSnapshot!.center = center
        case UIGestureRecognizerState.Ended:
            //My.cellSnapshot!.removeFromSuperview()
            //extraTasksTableView.reloadData()
            let locationInScheduleTable = longPress.locationInView(scheduleTableView)
            if let ip = scheduleTableView.indexPathForRowAtPoint(locationInScheduleTable) {
                // add cell to schedule model, remove it from extras model
                extrasModel.removeAtIndex(Path.initialIndexPath!.row)
                scheduleModel.append(ip.row)
            }
            My.cellSnapshot?.removeFromSuperview()
            extraTasksTableView.reloadData()
            scheduleTableView.reloadData()
            Path.initialIndexPath = nil
            My.cellSnapshot = nil
        default: break
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
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
}
