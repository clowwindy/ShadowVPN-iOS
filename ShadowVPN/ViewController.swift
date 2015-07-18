//
//  ViewController.swift
//  ShadowVPN
//
//  Created by clowwindy on 7/18/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler() { newManagers, error in
      guard let vpnManagers = newManagers else { return }
      for vpnManager in vpnManagers {
        // remove existing managers
        vpnManager.removeFromPreferencesWithCompletionHandler({ error -> Void in
        })
      }
    }
    
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
