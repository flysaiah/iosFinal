//
//  TaskBuilderViewController.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/14/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit

class TaskBuilderViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Private data
    
    private var tasks = [Task]()
    private var currentlyEditing = false;
    
    // MARK: IBOutlets/Actions
    
    @IBOutlet weak var enterTaskField: UITextField!
    @IBOutlet weak var etField: UITextField!
    @IBOutlet weak var prioritySwitch: UISwitch!
    @IBOutlet weak var taskTable: UITableView!
    
    @IBAction func addTask(sender: UIButton) {
        if enterTaskField.text == nil || enterTaskField.text == "" {
            validationError("no title")
        } else if etField.text == nil || etField.text! == "" {
            validationError("no ETC")
        } else if let ET = NSNumberFormatter().numberFromString(etField.text!) {
            let newTask = Task(title: enterTaskField.text!, estimatedTime: Int(ET), highPriority: prioritySwitch.on)
            tasks.append(newTask)
            taskTable.reloadData()
            
            // reset fields
            enterTaskField.text = ""
            etField.text = ""
        } else {
            validationError("bad ETC")
        }
    }
    
    // MARK: TextField delegate functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Table view delegate functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Task Cell", forIndexPath: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].title
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: Public API
    
    func getTasks() -> [Task] {
        return tasks
    }
    
    // MARK: Internal functions
    
    private func validationError(type: String) {
        // Displays alert dialog when user doesn't fill out input fields right
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
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if !currentlyEditing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let movementDuration:NSTimeInterval = 0.3
                let movement:CGFloat = -1 * keyboardSize.height
                UIView.beginAnimations("animateView", context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(movementDuration)
                self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
                UIView.commitAnimations()
                currentlyEditing = true
            }
        }

    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let movementDuration:NSTimeInterval = 0.3
            let movement:CGFloat = keyboardSize.height
            UIView.beginAnimations("animateView", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(movementDuration)
            self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
            UIView.commitAnimations()
            currentlyEditing = false;
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //enterTaskField.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
