//
//  PacketTunnelProvider.swift
//  tunnel
//
//  Created by clowwindy on 7/18/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    var session: NWUDPSession? = nil
    var conf = [String: AnyObject]()
    var pendingStartCompletion: (NSError? -> Void)?
    var userToken: NSData?
    var chinaDNS: ChinaDNSRunner?
    var routeManager: RouteManager?
//    var wifi = ChinaDNSRunner.checkWiFiNetwork()
    var queue: dispatch_queue_t?
    
    override func startTunnelWithOptions(options: [String : NSObject]?, completionHandler: (NSError?) -> Void) {
        queue = dispatch_queue_create("shadowvpn.queue", DISPATCH_QUEUE_SERIAL)
        conf = (self.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        self.pendingStartCompletion = completionHandler
        chinaDNS = ChinaDNSRunner(DNS: conf["dns"] as? String)
        if let userTokenString = conf["usertoken"] as? String {
            if userTokenString.characters.count == 16 {
                userToken = NSData.fromHexString(userTokenString)
            }
        }
        NSLog("setPassword")
        SVCrypto.setPassword(conf["password"] as! String)
        self.recreateUDP()
        let keyPath = "defaultPath"
        let options = NSKeyValueObservingOptions([.New, .Old])
        self.addObserver(self, forKeyPath: keyPath, options: options, context: nil)
        NSLog("readPacketsFromTUN")
        self.readPacketsFromTUN()
    }
    
    func recreateUDP() {
        if self.session != nil {
            self.reasserting = true
            self.session = nil
        }
        dispatch_async(queue!) { () -> Void in
            if let serverAddress = self.protocolConfiguration.serverAddress {
                if let port = self.conf["port"] as? String {
                    self.reasserting = false
                    self.setTunnelNetworkSettings(nil) { (error: NSError?) -> Void in
                        if let error = error {
                            NSLog("%@", error)
                            // simply kill the extension process since it does no harm and ShadowVPN is expected to be always on
//                            exit(1)
                        }
                        dispatch_async(self.queue!) { () -> Void in
                            NSLog("recreateUDP")
                            self.session = self.createUDPSessionToEndpoint(NWHostEndpoint(hostname: serverAddress, port: port), fromEndpoint: nil)
                            self.updateNetwork()
                        }
                    }
                }
            }
        }
    }
    
    func updateNetwork() {
        NSLog("updateNetwork")
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: self.protocolConfiguration.serverAddress!)
        newSettings.IPv4Settings = NEIPv4Settings(addresses: [conf["ip"] as! String], subnetMasks: [conf["subnet"] as! String])
        routeManager = RouteManager(route: conf["route"] as? String, IPv4Settings: newSettings.IPv4Settings!)
        if conf["mtu"] != nil {
            newSettings.MTU = Int(conf["mtu"] as! String)
        } else {
            newSettings.MTU = 1432
        }
        if "chnroutes" == (conf["route"] as? String) {
            NSLog("using ChinaDNS")
            newSettings.DNSSettings = NEDNSSettings(servers: ["127.0.0.1"])
        } else {
            NSLog("using DNS")
            newSettings.DNSSettings = NEDNSSettings(servers: (conf["dns"] as! String).componentsSeparatedByString(","))
        }
        NSLog("setTunnelNetworkSettings")
        self.setTunnelNetworkSettings(newSettings) { (error: NSError?) -> Void in
            self.readPacketsFromUDP()
            NSLog("readPacketsFromUDP")
            if let completionHandler = self.pendingStartCompletion {
                // send an packet
                //        self.log("completion")
                NSLog("%@", String(error))
                NSLog("VPN started")
                completionHandler(error)
                if error != nil {
                    // simply kill the extension process since it does no harm and ShadowVPN is expected to be always on
                    exit(1)
                }
            }
        }
    }
    
    func readPacketsFromTUN() {
        self.packetFlow.readPacketsWithCompletionHandler {
            packets, protocols in
            for packet in packets {
//                NSLog("TUN: %d", packet.length)
                self.session?.writeDatagram(SVCrypto.encryptWithData(packet, userToken: self.userToken), completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        NSLog("%@", error)
//                        self.recreateUDP()
//                        return
                    }
                })
            }
            self.readPacketsFromTUN()
        }
        
    }
    
    func readPacketsFromUDP() {
        session?.setReadHandler({ (newPackets: [NSData]?, error: NSError?) -> Void in
            //      self.log("readPacketsFromUDP")
            guard let packets = newPackets else { return }
            var protocols = [NSNumber]()
            var decryptedPackets = [NSData]()
            for packet in packets {
//                NSLog("UDP: %d", packet.length)
                // currently IPv4 only
                let decrypted = SVCrypto.decryptWithData(packet, userToken: self.userToken)
//                NSLog("write to TUN: %d", decrypted.length)
                decryptedPackets.append(decrypted)
                protocols.append(2)
            }
            self.packetFlow.writePackets(decryptedPackets, withProtocols: protocols)
            }, maxDatagrams: NSIntegerMax)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let object = object {
            if object as! NSObject == self {
                if let keyPath = keyPath {
                    if keyPath == "defaultPath" {
                        // commented out since when switching from 4G to Wi-Fi, this will be called multiple times, only the last time works
//                        let wifi = ChinaDNSRunner.checkWiFiNetwork()
//                        if wifi != self.wifi {
                            NSLog("Wi-Fi status changed")
//                            self.wifi = wifi
                            self.recreateUDP()
//                            return
//                        }

                    }
                }
            }
        }
    }
    
    override func stopTunnelWithReason(reason: NEProviderStopReason, completionHandler: () -> Void) {
        // Add code here to start the process of stopping the tunnel
        NSLog("stopTunnelWithReason")
        session?.cancel()
        completionHandler()
        super.stopTunnelWithReason(reason, completionHandler: completionHandler)
        // simply kill the extension process since it does no harm and ShadowVPN is expected to be always on
        exit(0)
    }
    
    override func handleAppMessage(messageData: NSData, completionHandler: ((NSData?) -> Void)?) {
        // Add code here to handle the message
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleepWithCompletionHandler(completionHandler: () -> Void) {
        // Add code here to get ready to sleep
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up
    }
}
