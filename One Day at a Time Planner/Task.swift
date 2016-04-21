//
//  Task.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/19/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import Foundation

class Task: CustomStringConvertible {
    var title: String
    var desc: String?
    var estimatedTime: Int
    var highPriority: Bool
    
    required init(title t: String, description d: String?, estimatedTime et: Int, highPriority hp: Bool) {
        title = t
        if let text = d {
            if text != "" {desc = text}
        }
        estimatedTime = et
        highPriority = hp
    }
    
    var description: String {
        get {
            return "Task(\(title), \(desc), \(estimatedTime), \(highPriority))"
        }
    }
}
