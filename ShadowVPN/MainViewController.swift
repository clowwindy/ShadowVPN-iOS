//
//  MainViewController.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/6/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension

class MainViewController: UITableViewController {
    
    var vpnManagers = [NETunnelProviderManager]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ShadowVPN"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addConfiguration")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadConfigurationFromSystem()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vpnManager = self.vpnManagers[indexPath.row]
        vpnManager.enabled = true
        vpnManager.saveToPreferencesWithCompletionHandler { (error) -> Void in
            self.loadConfigurationFromSystem()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vpnManagers.count
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
            providerProtocol.providerBundleIdentifier = "clowwindy.ShadowVPN.tunnel"
            providerProtocol.providerConfiguration = [String: AnyObject]()
            manager.protocolConfiguration = providerProtocol
            
            let configurationController = ConfigurationViewController(style:.Grouped)
            configurationController.providerManager = manager
            self.navigationController?.pushViewController(configurationController, animated: true)
            manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
                print(error)
            })
        }
    }
    
    func loadConfigurationFromSystem() {
        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler() { newManagers, error in
            print(error)
            guard let vpnManagers = newManagers else { return }
            self.vpnManagers.removeAll()
            for vpnManager in vpnManagers {
                // TODO filter ShadowVPN
                self.vpnManagers.append(vpnManager)
            }
            self.tableView.reloadData()
        }
    }

}
