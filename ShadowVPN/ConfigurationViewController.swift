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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = providerManager?.protocolConfiguration?.serverAddress
        let conf:NETunnelProviderProtocol = self.providerManager?.protocolConfiguration as! NETunnelProviderProtocol
        
        if conf.providerConfiguration!["ShadowVPN"] == nil {
            conf.providerConfiguration!["ShadowVPN"] = [String: AnyObject]()
        }
        self.configuration = conf.providerConfiguration!
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        for (k, v) in self.bindMap {
            self.configuration[k] = v.text
        }
        (self.providerManager?.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration = self.configuration
        self.providerManager?.protocolConfiguration?.serverAddress = self.configuration["server"] as? String
        
        self.providerManager?.saveToPreferencesWithCompletionHandler { (error) -> Void in
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
            return 7
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
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Description"
                cell.textField.placeholder = "Optional"
                bindData(cell.textField, property: "description")
            case 1:
                cell.textLabel?.text = "Server"
                cell.textField.placeholder = "Server IP"
                bindData(cell.textField, property: "server")
            case 2:
                cell.textLabel?.text = "Port"
                cell.textField.placeholder = "Server Port"
                bindData(cell.textField, property: "port")
            case 3:
                cell.textLabel?.text = "Password"
                cell.textField.placeholder = "Required"
                bindData(cell.textField, property: "password")
            case 4:
                cell.textLabel?.text = "User Token"
                cell.textField.placeholder = "Optional"
                bindData(cell.textField, property: "usertoken")
            case 5:
                cell.textLabel?.text = "DNS"
                cell.textField.placeholder = "DNS Server Address"
                bindData(cell.textField, property: "dns")
            case 6:
                cell.textLabel?.text = "CHNRoutes"
                cell.textField.placeholder = "TODO"
                bindData(cell.textField, property: "chnroutes")
                break
            default:
                break
            }
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Delete This Configuration"
            return cell
        default:
            return UITableViewCell()
        }
    }
    

}
