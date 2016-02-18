//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Joe on 16/1/17.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit
import NotificationCenter

let groupBundle = "group.VPNCare.shadowVPN"

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var statusSwitch: UISwitch!
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        preferredContentSize = CGSizeMake(0, 50)
        configureUI()
        
        statusSwitch.addTarget(self, action: "statusSwitchValueChanged:", forControlEvents: .ValueChanged)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "setStatusSwitchState", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    func configureUI() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 31))
        setLabelDisplayText(label)
        
        statusSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 31))
        statusSwitch.on = false
        setStatusSwitchState()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        statusSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let labelConstraintCenterY = NSLayoutConstraint(item: label,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0)
        
        let labelConstraingLeading = NSLayoutConstraint(item: label,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Leading,
            multiplier: 1,
            constant: 0)
        
        let statusSwitchConstraintCenterY = NSLayoutConstraint(item: statusSwitch,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: label,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0)
        
        let statusSwitchConstraintTailling = NSLayoutConstraint(item: statusSwitch,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Trailing,
            multiplier: 1,
            constant: -20)
        
        let constrants = [labelConstraintCenterY, labelConstraingLeading, statusSwitchConstraintCenterY, statusSwitchConstraintTailling]
        
        view.addSubview(label)
        view.addSubview(statusSwitch)
        view.addConstraints(constrants)

    }
    
    func setLabelDisplayText(label: UILabel) {
        label.textColor = UIColor.whiteColor()
        
        let shared = NSUserDefaults(suiteName: groupBundle)
        if let text = shared?.valueForKey("currentVPN") as? String {
            label.text = text
        } else {
            label.text = "missing configurations"
        }
    }
    
    func setStatusSwitchState() {
        let shared = NSUserDefaults(suiteName: groupBundle)!
        let state = shared.boolForKey("vpnState")
        statusSwitch.on = state
    }
    
    func statusSwitchValueChanged(sender: UISwitch) {
        let urlSchema = "shadowvpn"
        var host: String
        if sender.on {
            host = "start"
        } else {
            host = "stop"
        }
        let url = urlSchema + "://" + host
        
        extensionContext?.openURL(NSURL(string: url)!, completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 0, right: defaultMarginInsets.right)
        return inset
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
