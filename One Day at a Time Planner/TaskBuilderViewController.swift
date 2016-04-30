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
            enterTaskField.becomeFirstResponder()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Task Cell", forIndexPath: indexPath) as! TaskBuilderTVCell   // There is only one prototype cell, so we know we can cast it
        cell.taskLabel.text = tasks[indexPath.row].description
        cell.priorityLabel.text = tasks[indexPath.row].getPriority() ? "Priority" : ""
            
        // to achieve bottom-anchored tablecell behavior
        cell.contentView.transform = CGAffineTransformMakeScale(1, -1)
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
        // ensures keyboard won't cover input fields
        if !currentlyEditing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                UIView.beginAnimations("animateView", context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(0.3)
                self.view.frame = CGRectOffset(self.view.frame, 0,  keyboardSize.height * -1)
                UIView.commitAnimations()
                currentlyEditing = true
            }
        }

    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // reset view
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            UIView.beginAnimations("animateView", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            self.view.frame = CGRectOffset(self.view.frame, 0,  keyboardSize.height)
            UIView.commitAnimations()
            currentlyEditing = false;
        }
    }
    
    private func addObservers() {
        // add observers to keyboard showing/hiding
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func addGestures() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.taskTable.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: Life cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        enterTaskField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        addGestures()

        
        // to achieve bottom-anchored tablecell behavior
        self.taskTable.transform = CGAffineTransformMakeScale(1, -1)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
}
