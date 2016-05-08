//
//  Task.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/19/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import Foundation

class Task: NSObject, NSCoding {
    private var title: String
    private var estimatedTime: Int
    private var highPriority: Bool
    
    static var counter = 0
    
    @objc required init(title t: String, estimatedTime et: Int, highPriority hp: Bool) {
        title = t
        estimatedTime = et
        highPriority = hp
        Task.counter += 1
    }
    
    @objc required convenience init(coder aDecoder: NSCoder) {
        let t = aDecoder.decodeObjectForKey("title") as! String
        let et = Int(aDecoder.decodeIntForKey("estimatedTime"))
        let hp = aDecoder.decodeBoolForKey("highPriority")
        self.init(title: t, estimatedTime: et, highPriority: hp)
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeInt(Int32(estimatedTime), forKey: "estimatedTime")
        aCoder.encodeBool(highPriority, forKey: "highPriority")
    }
    
    override var description: String {
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
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherTask = object as? Task {
            if otherTask.description == description && otherTask.getPriority() == highPriority {
                return true
            }
        }
        return false
    }
}

struct todoInfo {
    var tasks: [Task]
    var freeTime: [(Double, Double)]
}