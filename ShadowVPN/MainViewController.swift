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
    
    var configurations = [VPNConfiguration]()
    var vpnManagers = [NETunnelProviderManager]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadConfigurationFromSystem()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "configuration")
        let configuration = self.configurations[indexPath.row]
        cell.textLabel?.text = configuration.server
        cell.accessoryType = .DetailDisclosureButton
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configurations.count
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
    }
    
    func loadConfigurationFromSystem() {
        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler() { newManagers, error in
            guard let vpnManagers = newManagers else { return }
            self.configurations.removeAll()
            self.vpnManagers.removeAll()
            for vpnManager in vpnManagers {
                self.vpnManagers.append(vpnManager)
            }
        }
    }
    
    func saveConfigurationsToSystem() {
//        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler() { newManagers, error in
//            guard let vpnManagers = newManagers else { return }
//            for vpnManager in vpnManagers {
//                // remove existing managers
//                vpnManager.removeFromPreferencesWithCompletionHandler({ error -> Void in
//                })
//            }
//        }
        
        let manager = NETunnelProviderManager()
        manager.loadFromPreferencesWithCompletionHandler { (error) -> Void in
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = "clowwindy.ShadowVPN.tunnel"
            providerProtocol.providerConfiguration = [String: AnyObject]()
            providerProtocol.serverAddress = "10.0.1.118"
            manager.protocolConfiguration = providerProtocol
            manager.enabled = true
            
            manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
                print(error)
            })
        }

    }

}
