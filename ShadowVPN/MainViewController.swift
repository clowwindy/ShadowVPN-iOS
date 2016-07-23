//
//  MainViewController.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/6/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension

let kTunnelProviderBundle = "VPNCare.ShadowVPN.tunnel"
let enableCurrentVPNManagerVPNStateFromWidget = "VPNCare.ShadowVPN.enableCurrentVPNManagerVPNStateFromWidget"
let groupBundle = "group.VPNCare.shadowVPN"


class MainViewController: UITableViewController {
    
    var vpnManagers = [NETunnelProviderManager]()
    var currentVPNManager: NETunnelProviderManager? {
        didSet {
            self.shareVPNDescriptionToUserDefauls(currentVPNManager!)
        }
    }
    var vpnStatusSwitch = UISwitch()
    var vpnStatusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ShadowVPN"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addConfiguration")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("VPNStatusDidChange:"), name: NEVPNStatusDidChangeNotification, object: nil)
        vpnStatusSwitch.addTarget(self, action: "vpnStatusSwitchValueDidChange:", forControlEvents: .ValueChanged)
//        vpnStatusLabel.textAlignment = .Right
//        vpnStatusLabel.textColor = UIColor.grayColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationFromWidget:",
            name: enableCurrentVPNManagerVPNStateFromWidget, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NEVPNStatusDidChangeNotification, object: nil)
    }
    
    func notificationFromWidget(notification: NSNotification) -> Bool {
        // 从通知中心操作
        let command = notification.userInfo!["command"] as! String
        do {
            if let currentVPNManager = self.currentVPNManager {
                if command == "start" {
                    if currentVPNManager.enabled == false {
                        currentVPNManager.enabled = true
                        currentVPNManager.saveToPreferencesWithCompletionHandler { (error) -> Void in
                            self.loadConfigurationFromSystem()
                        }
                    }
                    try currentVPNManager.connection.startVPNTunnel()
                    return true
                }
                else {
                    currentVPNManager.connection.stopVPNTunnel()
                }
            } else {
                NSLog("No current vpn manager")
            }
        } catch {
            NSLog("%@", String(error))
        }
        return false
    }
    
    func vpnStatusSwitchValueDidChange(sender: UISwitch) {
        do {
            if vpnManagers.count > 0 {
                if let currentVPNManager = self.currentVPNManager {
                    if sender.on {
                        try currentVPNManager.connection.startVPNTunnel()
                    } else {
                        currentVPNManager.connection.stopVPNTunnel()
                    }
                }
            }
        } catch {
            NSLog("%@", String(error))
        }
    }

    func VPNStatusDidChange(notification: NSNotification?) {
        var on = false
        var enabled = false
        if let currentVPNManager = self.currentVPNManager {
            let status = currentVPNManager.connection.status
            switch status {
            case .Connecting:
                on = true
                enabled = false
                vpnStatusLabel.text = "Connecting..."
                break
            case .Connected:
                on = true
                enabled = true
                vpnStatusLabel.text = "Connected"
                break
            case .Disconnecting:
                on = false
                enabled = false
                vpnStatusLabel.text = "Disconnecting..."
                break
            case .Disconnected:
                on = false
                enabled = true
                vpnStatusLabel.text = "Not Connected"
                break
            default:
                on = false
                enabled = true
                break
            }
            vpnStatusSwitch.on = on
            vpnStatusSwitch.enabled = enabled
            UIApplication.sharedApplication().networkActivityIndicatorVisible = !enabled
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadConfigurationFromSystem()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "status")
            cell.selectionStyle = .None
            cell.textLabel?.text = "Status"
            vpnStatusLabel = cell.detailTextLabel!
            cell.accessoryView = vpnStatusSwitch
            return cell
        } else {
            let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "configuration")
            let vpnManager = self.vpnManagers[indexPath.row]
            cell.textLabel?.text = vpnManager.protocolConfiguration?.serverAddress
            cell.detailTextLabel?.text = (vpnManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!["description"] as? String
            if vpnManager.enabled {
                cell.imageView?.image = UIImage(named: "checkmark")
            } else {
                cell.imageView?.image = UIImage(named: "checkmark_empty")
            }
            cell.accessoryType = .DetailButton
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let vpnManager = self.vpnManagers[indexPath.row]
            vpnManager.enabled = true
            vpnManager.saveToPreferencesWithCompletionHandler { (error) -> Void in
                self.loadConfigurationFromSystem()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.vpnManagers.count
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let configurationController = ConfigurationViewController(style:.Grouped)
        configurationController.providerManager = self.vpnManagers[indexPath.row]
        self.navigationController?.pushViewController(configurationController, animated: true)
    }
    
    func addConfiguration() {
        let manager = NETunnelProviderManager()
        manager.loadFromPreferencesWithCompletionHandler { (error) -> Void in
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = kTunnelProviderBundle
            providerProtocol.providerConfiguration = [String: AnyObject]()
            manager.protocolConfiguration = providerProtocol
            
            providerProtocol.serverAddress = "ShadowVPN"
            
            let configurationController = ConfigurationViewController(style:.Grouped)
            configurationController.providerManager = manager
            self.navigationController?.pushViewController(configurationController, animated: true)
//            manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
//                print(error)
//            })
        }
    }
    
    func loadConfigurationFromSystem() {
        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler() { newManagers, error in
            if (error != nil) {
                print(error)
            }
            guard let vpnManagers = newManagers else { return }
            self.vpnManagers.removeAll()
            for vpnManager in vpnManagers {
                if let providerProtocol = vpnManager.protocolConfiguration as? NETunnelProviderProtocol {
                    if providerProtocol.providerBundleIdentifier == kTunnelProviderBundle {
                        if vpnManager.enabled {
                            self.currentVPNManager = vpnManager
                        }
                        self.vpnManagers.append(vpnManager)
                    }
                }
            }
            self.vpnStatusSwitch.enabled = vpnManagers.count > 0
            self.tableView.reloadData()
            self.VPNStatusDidChange(nil)
        }
    }
    
    func shareVPNDescriptionToUserDefauls(VPNManager: NETunnelProviderManager) {
        let configuration = (VPNManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        let shared = NSUserDefaults(suiteName: groupBundle)
        
        if (configuration["description"] != nil && !(configuration["description"] as! String).isEmpty) {
            shared?.setValue(configuration["description"], forKey: "currentVPN")
        } else {
            shared?.setValue(VPNManager.protocolConfiguration?.serverAddress, forKey: "currentVPN")
        }
        shared?.synchronize()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    // override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //     super.tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    // }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            self.shareConfiguration(indexPath: indexPath)
        }
        return [shareAction]
    }
    
    func shareConfiguration(indexPath indexPath: NSIndexPath) {
        let selectManager = self.vpnManagers[indexPath.row]
        
        let configuration: [String: AnyObject] = (selectManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        
        var query =  String()
        for (k, v) in configuration {
            let customAllowSet = NSCharacterSet(charactersInString: "#%/<>?@\\^`{|}=& ").invertedSet
            let value: String = (v as! String).stringByAddingPercentEncodingWithAllowedCharacters(customAllowSet)!
            
            if !query.isEmpty {
                query += "&\(k)=\(value)"
            } else {
                query = "shadowvpn://QRCode?" + "\(k)=\(value)"
            }
        }
        
        let shareVC = QRCodeShareVC()
        shareVC.configQuery = query
        self.navigationController?.pushViewController(shareVC, animated: true)
    }
    
}
