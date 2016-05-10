//
//  TaskScheduleCell.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 5/5/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

class TaskScheduleCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    var task: Task? {
        didSet {
            setProperties()
        }
    }
    
    private func setProperties() {
        taskLabel.text = "\(task!.getTitle()): \(task!.getEstimatedTime()) min"
        
        priorityLabel.text = task!.getPriority() ? "!" : ""
    }
}
