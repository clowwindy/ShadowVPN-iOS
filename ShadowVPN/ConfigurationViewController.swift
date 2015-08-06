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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO add UI
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = providerManager?.protocolConfiguration?.serverAddress
        print(providerManager)
    }

    

}
