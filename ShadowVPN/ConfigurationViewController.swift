//
//  ConfigurationViewController.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/6/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension


class ConfigurationViewController: UITableViewController {
    var providerManager: NETunnelProviderManager?
    var bindMap = [String: UITextField]()
    var configuration = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        self.title = providerManager?.protocolConfiguration?.serverAddress
        let conf:NETunnelProviderProtocol = self.providerManager?.protocolConfiguration as! NETunnelProviderProtocol
        // Dictionary in Swift is a struct. This is a copy
        self.configuration = conf.providerConfiguration!
    }
    
    func updateConfiguration() {
        for (k, v) in self.bindMap {
            self.configuration[k] = v.text
        }
//        self.configuration["route"] = "chnroutes"
    }
    
    func save() {
        updateConfiguration()
        if let result = ConfigurationValidator.validate(self.configuration) {
            let alertController = UIAlertController(title: "Error", message: result, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
            }))
            self.presentViewController(alertController, animated: true, completion: { () -> Void in
            })
            return
        }
        (self.providerManager?.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration = self.configuration
        self.providerManager?.protocolConfiguration?.serverAddress = self.configuration["server"] as? String
        self.providerManager?.localizedDescription = self.configuration["server"] as? String
        
        self.providerManager?.saveToPreferencesWithCompletionHandler { (error) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func bindData(textField: UITextField, property: String) {
        let val: AnyObject? = configuration[property]
        if let val = val {
            textField.text = String(val)
        }
        bindMap[property] = textField
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 10
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = ConfigurationTextCell()
            cell.selectionStyle = .None
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Description"
                cell.textField.placeholder = "Optional"
                bindData(cell.textField, property: "description")
            case 1:
                cell.textLabel?.text = "Server"
                cell.textField.placeholder = "Server IP"
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                bindData(cell.textField, property: "server")
            case 2:
                cell.textLabel?.text = "Port"
                cell.textField.placeholder = "Server Port"
                cell.textField.text = "1123"
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.keyboardType = .NumberPad
                bindData(cell.textField, property: "port")
            case 3:
                cell.textLabel?.text = "Password"
                cell.textField.placeholder = "Required"
                cell.textField.text = ""
                cell.textField.secureTextEntry = true
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                bindData(cell.textField, property: "password")
            case 4:
                cell.textLabel?.text = "User Token"
                cell.textField.placeholder = "Optional"
                cell.textField.text = ""
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                bindData(cell.textField, property: "usertoken")
            case 5:
                cell.textLabel?.text = "IP"
                cell.textField.placeholder = "Required"
                cell.textField.text = "10.7.0.2"
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.keyboardType = .DecimalPad
                bindData(cell.textField, property: "ip")
            case 6:
                cell.textLabel?.text = "Subnet"
                cell.textField.placeholder = "Required"
                cell.textField.text = "255.255.255.0"
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.keyboardType = .DecimalPad
                bindData(cell.textField, property: "subnet")
            case 7:
                cell.textLabel?.text = "DNS"
                cell.textField.placeholder = "DNS Server Address"
                cell.textField.text = "114.114.114.114,223.5.5.5,8.8.8.8,8.8.4.4,208.67.222.222"
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                bindData(cell.textField, property: "dns")
            case 8:
                cell.textLabel?.text = "MTU"
                cell.textField.placeholder = "MTU"
                cell.textField.text = "1350"
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.keyboardType = .NumberPad
                bindData(cell.textField, property: "mtu")
            case 9:
                cell.textLabel?.text = "Route"
                cell.textField.text = "chnroutes"
                cell.textField.enabled = false
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
                bindData(cell.textField, property: "route")
                return cell
            default:
                break
            }
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Delete This Configuration"
            cell.textLabel?.textColor = UIColor.redColor()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 0) {
            if (indexPath.row == 9) {
                let controller = SimpleTableViewController(labels: ["Default", "CHNRoutes"], values: ["default", "chnroutes"], initialValue: self.configuration["route"] as? String, selectionBlock: { (result) -> Void in
                    // else we'll lost unsaved modifications
                    self.updateConfiguration()
                    self.configuration["route"] = result
                    self.tableView.reloadData()
                })
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else if (indexPath.section == 1) {
            let alertController = UIAlertController(title: nil, message: "Delete this configuration?", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                self.providerManager?.removeFromPreferencesWithCompletionHandler({ (error) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            }))
            self.presentViewController(alertController, animated: true, completion: { () -> Void in
            })
        }
    }
    

}
