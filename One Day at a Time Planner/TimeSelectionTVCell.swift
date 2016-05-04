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
    
    private var selectedParts = (false, false, false, false) {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("TimeSelectionCellModelUpdate", object: self)
        }
    }
    
    var hour: Int?
    private var firstTimeSetup = true
    
    override func awakeFromNib() {
        // This is only run once for each cell
        super.awakeFromNib()
        self.allowsMultipleSwipe = true
        let x = MGSwipeSettings()
        x.bottomMargin = 2.0
        x.topMargin = 2.0
        self.leftSwipeSettings = x
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        // we do things here instead of in awakeFromNib because some info wasn't available before (like correct contentView.frame.size.width)
        if firstTimeSetup {
            firstTimeSetup = false
            self.leftButtons = makeButtons()
            setButtonTitles()
            makeCallBacks()
            updateTimeModel()
        }
        updateUI()
    }
    
    
    
    private struct colorCode {
        static let active = UIColor.grayColor()
        static let inactive = UIColor.whiteColor()
    }
    
    private struct Constants {
        private static let numberOfButtons = 4
    }
    
    
    private func setButtonTitles() {
        for i in 0...(Constants.numberOfButtons-1) {
            if let hr = hour {
                var minutes = "\(60/Constants.numberOfButtons * i)"
                if minutes == "0" {minutes = "00"}
                self.leftButtons[i].setTitle("\(hr):\(minutes)", forState: UIControlState.Normal)
            }

        }
    }
    
    private func makeButtons() -> [MGSwipeButton] {
        var buttonArr = [MGSwipeButton]()
        for _ in 0...(Constants.numberOfButtons-1) {
            let button = MGSwipeButton(title: "", backgroundColor: colorCode.inactive)
            //button.buttonWidth = self.contentView.frame.size.width / (CGFloat(Constants.numberOfButtons)+3)
            button.buttonWidth = 414.0 / (CGFloat(Constants.numberOfButtons))
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            buttonArr.append(button)
        }
        return buttonArr
    }
    
    private func makeCallBacks() {
        for i in 0...(Constants.numberOfButtons-1) {
            if let button = self.leftButtons[i] as? MGSwipeButton {
                button.callback = { [weak self] (sender: MGSwipeTableCell!) -> Bool in
                    if button.backgroundColor == colorCode.inactive {
                        button.backgroundColor = colorCode.active
                    } else {
                        button.backgroundColor = colorCode.inactive
                    }
                    self!.updateUI()
                    self!.updateTimeModel()
                    return false
                }
            }

        }

    }
    
    @objc private func updateUI() {
        // Keep buttons out if at least one is active
        if atLeastOneButtonIsPressed() {
            showSwipe(MGSwipeDirection.LeftToRight, animated: false)
        }
    }
    
    private func updateTimeModel() {
        var tmp = [false, false, false, false, false, false, false]
        if self.selected {
            tmp[0] = true
        }
        for i in 0...(Constants.numberOfButtons-1) {
            if self.leftButtons[i].backgroundColor == colorCode.active {
                tmp[0] = false
                tmp[i+1] = true
            }
        }
        selectedParts = (tmp[0], tmp[1], tmp[2], tmp[3])
    }
    
    
    private func atLeastOneButtonIsPressed() -> Bool {
        for button in self.leftButtons {
            if button.backgroundColor == colorCode.active {
                return true
            }
        }
        return false
    }
    
    func getSelectionStatus() -> (Bool, Bool, Bool, Bool) {
        return selectedParts
    }
    
}
