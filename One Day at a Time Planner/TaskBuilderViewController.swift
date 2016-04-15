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
    
    var delegate: taskBuilderDelegate?
    
    
    @IBOutlet weak var enterTaskTextField: UITextField!
}
