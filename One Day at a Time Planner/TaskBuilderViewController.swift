//
//  TaskBuilderViewController.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/14/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

protocol taskBuilderDelegate: class {
    func getFreeTime() -> [(Int, Int)]
}

class TaskBuilderViewController: UIViewController {
    
    struct Task: CustomStringConvertible {
        var title: String
        var desc: String?
        var estimatedTime: Int
        
        var description: String {
            get {
                return "Task(\(title), \(desc), \(estimatedTime))"
            }
        }
    }
    
    private struct tbModel: CustomStringConvertible {
        var tasks: [Task]
        var freeTime: [(Int, Int)]
        
        var description: String {
            get {
                return "tbModel(Tasks: \(tasks), freeTime: \(freeTime)"
            }
        }
    }
    
    private var tbm = tbModel(tasks: [], freeTime: [])
    
    var delegate: taskBuilderDelegate? {
        didSet {
            tbm.freeTime = delegate!.getFreeTime()
        }
    }
    
    @IBOutlet weak var enterTaskField: UITextField!
    @IBOutlet weak var enterDescField: UITextField!
    
    // This should eventually be a different UI element
    @IBOutlet weak var etField: UITextField!
    
    @IBAction func addTask(sender: UIButton) {
        
        // This needs to be cleaned up later
        if let titleText = enterTaskField.text {
            if let est_time = etField.text {
                if let ET = NSNumberFormatter().numberFromString(est_time) {
                    let newTask = Task(title: titleText, desc: enterDescField.text, estimatedTime: Int(ET))
                    tbm.tasks.append(newTask)
                } else {
                    print("Error here")
                }
            } else {
                print("ERRRRRRRERRRRR")
            }
        } else {
            print("Error handling should be happening here")
        }
        
        print(String(tbm))
        
        // reset fields
        enterTaskField.text = ""
        enterDescField.text = ""
    }
}
