//
//  TimeSelectionTVCell.swift
//  One Day at a Time Planner
//
//  Created by Isaiah Mayerchak on 4/14/16.
//  Copyright © 2016 flysaiah. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TimeSelectionTVCell: MGSwipeTableCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.leftButtons = makeButtons()
    }
    
    private func makeButtons() -> [MGSwipeButton] {
        return [MGSwipeButton(title: "15", backgroundColor: UIColor.blueColor()), MGSwipeButton(title: "30", backgroundColor: UIColor.redColor()), MGSwipeButton(title: "45", backgroundColor: UIColor.greenColor())]
    }
    
    
}
