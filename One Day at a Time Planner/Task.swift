//
//  Task.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/19/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import Foundation

class Task: CustomStringConvertible {
    private var title: String
    private var estimatedTime: Int
    private var highPriority: Bool
    
    required init(title t: String, estimatedTime et: Int, highPriority hp: Bool) {
        title = t
        estimatedTime = et
        highPriority = hp
    }
    
    var description: String {
        get {
            return "\(title): \(estimatedTime) min"
        }
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getEstimatedTime() -> Int {
        return estimatedTime
    }
    
    func getPriority() -> Bool {
        return highPriority
    }
}

struct todoInfo {
    var tasks: [Task]
    var freeTime: [(Double, Double)]
}