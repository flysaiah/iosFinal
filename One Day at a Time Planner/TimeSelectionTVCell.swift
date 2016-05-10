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
    
    // MARK: Constants/Private data
    
    private var selectedParts: [Bool]? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("TimeSelectionCellModelUpdate", object: self)
        }
    }
    
    struct colorCode {
        static let active = UIColor.lightGrayColor()
        static let inactive = UIColor.whiteColor()
    }
    
    struct Constants {
        static let numberOfButtons = 4
    }
    
    private var firstTimeSetup = true
    
    // MARK: Data set by others
    
    var hour: Int?
    var selectedData: [Bool]?

    // MARK: Initialization
    
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
            reloadFromData()
            updateTimeModel()
        }
        updateUI()
    }
    
    private func setButtonTitles() {
        for i in 0..<Constants.numberOfButtons {
            if let hr = hour {
                var minutes = "\(60/Constants.numberOfButtons * i)"
                if minutes == "0" {minutes = "00"}
                self.leftButtons[i].setTitle("\(hr):\(minutes)", forState: UIControlState.Normal)
            }

        }
    }
    
    private func makeButtons() -> [MGSwipeButton] {
        var buttonArr = [MGSwipeButton]()
        for _ in 0..<Constants.numberOfButtons {
            let button = MGSwipeButton(title: "", backgroundColor: colorCode.inactive)
            button.buttonWidth = self.contentView.frame.size.width / (CGFloat(Constants.numberOfButtons))
            button.layer.borderWidth = 1
            button.layer.borderColor = purpleColor.value.CGColor
            button.setTitleColor(purpleColor.value, forState: UIControlState.Normal)
            button.backgroundColor = colorCode.inactive
            buttonArr.append(button)
        }
        return buttonArr
    }
    
    private func makeCallBacks() {
        for i in 0..<Constants.numberOfButtons {
            if let button = self.leftButtons[i] as? MGSwipeButton {
                button.callback = { [weak self] (sender: MGSwipeTableCell!) -> Bool in
                    if !button.hasBeenSelected() {
                        button.setSelectedStatus(true)
                    } else {
                        button.setSelectedStatus(false)
                    }
                    self?.updateTimeModel()
                    return false
                }
            }

        }
    }
    
    // MARK: Private updating functions
    
    @objc private func updateUI() {
        // Keep buttons out if at least one is active
        if !self.selected && atLeastOneButtonIsPressed() {
            showSwipe(MGSwipeDirection.LeftToRight, animated: false)
        }
    }
    
    private func reloadFromData() {
        if let data = selectedData {
            if data[0] != true {   // First index is a flag for "the entire thing is selected"
                for index in 0..<Constants.numberOfButtons {
                    if data[index+1] == true {
                        if let button = self.leftButtons[index] as? MGSwipeButton {
                            button.backgroundColor = colorCode.active
                        }
                    }
                }
            }
            
        }
        
    }
    
    // MARK: Private auxilliary functions
    
    private func atLeastOneButtonIsPressed() -> Bool {
        for button in self.leftButtons {
            if button.hasBeenSelected() {
                return true
            }
        }
        return false
    }
    
    // MARK: Public API
    
    func getSelectionStatus() -> [Bool] {
        if let sp = selectedParts {
            return sp
        }
        fatalError("selectedParts in TimeSelectionTVCell has a value of nil")
    }
    
    func updateTimeModel() {
        var tmp = [Bool](count: Constants.numberOfButtons+1, repeatedValue: false)
        if self.selected {
            tmp[0] = true
            for i in 1..<tmp.count {
                tmp[i] = false
            }
        } else {
            for i in 0..<Constants.numberOfButtons {
                if self.leftButtons[i].hasBeenSelected() {
                    tmp[0] = false
                    tmp[i+1] = true
                }
            }
        }

        selectedParts = tmp
    }
    
}

extension MGSwipeButton {
    func hasBeenSelected() -> Bool {
        if self.backgroundColor == TimeSelectionTVCell.colorCode.active {
            return true
        } else {
            return false
        }
    }
    
    func setSelectedStatus(bool: Bool) {
        if (bool) {
            self.backgroundColor = TimeSelectionTVCell.colorCode.active
        } else {
            self.backgroundColor = TimeSelectionTVCell.colorCode.inactive
        }
    }
}
