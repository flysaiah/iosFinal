//
//  TaskBuilderViewController.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/14/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

class TaskBuilderViewController: UIViewController {
    
    // MARK: Model
    
    private var tasks = [Task]()
    
    // MARK: IBOutlets/Actions
    
    @IBOutlet weak var enterTaskField: UITextField!
    @IBOutlet weak var enterDescField: UITextField!
    @IBOutlet weak var etField: UITextField!
    @IBOutlet weak var prioritySwitch: UISwitch!

    @IBAction func addTask(sender: UIButton) {
        if enterTaskField.text == nil || enterTaskField.text == "" {
            validationError("no title")
        } else if etField.text == nil || etField.text! == "" {
            validationError("no ETC")
        } else if let ET = NSNumberFormatter().numberFromString(etField.text!) {
            let newTask = Task(title: enterTaskField.text!, description: enterDescField.text, estimatedTime: Int(ET), highPriority: prioritySwitch.on)
            tasks.append(newTask)
            
            // reset fields
            enterTaskField.text = ""
            enterDescField.text = ""
            etField.text = ""
        } else {
            validationError("bad ETC")
        }
    }
    
    // MARK: Public functions
    
    func getTasks() -> [Task] {
        return tasks
    }
    
    // MARK: Internal functions
    
    private func validationError(type: String) {
        var message: String
        switch type {
            case "bad ETC":
                message = "You must enter an integer for ETC"

            case "no ETC":
                message = "You must enter the estimated time to complete"

            case "no title":
                message = "You must enter a title for your task"

            default: message = "Bad input"
        }
        let alert = UIAlertController(title: "Bad input", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
