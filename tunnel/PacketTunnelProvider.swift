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
  var pendingStartCompletion: (NSError? -> Void)?

	override func startTunnelWithOptions(options: [String : NSObject]?, completionHandler: (NSError?) -> Void) {
		if let serverAddress = self.protocolConfiguration.serverAddress {
          session = self.createUDPSessionToEndpoint(NWHostEndpoint(hostname: serverAddress, port: "1123"), fromEndpoint: nil)
          self.pendingStartCompletion = completionHandler
          self.updateNetwork()
		} else {
			completionHandler(NSError(domain:"PacketTunnelProviderDomain", code:-1, userInfo:[NSLocalizedDescriptionKey:"Configuration is missing serverAddress"]))
		}
	}
  
  func log(data: String) {
    self.session?.writeDatagram(data.dataUsingEncoding(NSUTF8StringEncoding)!, completionHandler: { (error: NSError?) -> Void in
    })
  }
  
  func updateNetwork() {
    let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: self.protocolConfiguration.serverAddress!)
    newSettings.IPv4Settings = NEIPv4Settings(addresses: ["10.7.0.2"], subnetMasks: ["255.255.0.0"])
    newSettings.IPv4Settings!.includedRoutes = [NEIPv4Route.defaultRoute()]
    newSettings.tunnelOverheadBytes = 64
    newSettings.DNSSettings = NEDNSSettings(servers: ["8.8.8.8"])
    SVCrypto.setPassword("my_password")
    self.setTunnelNetworkSettings(newSettings) { (error: NSError?) -> Void in
      self.readPacketsFromTUN()
      self.readPacketsFromUDP()
      if let completionHandler = self.pendingStartCompletion {
        // send an packet
//        self.log("completion")
        completionHandler(error)
      }
    }
  }
  
  func readPacketsFromTUN() {
    self.packetFlow.readPacketsWithCompletionHandler {
      packets, protocols in
//      self.log("readPacketsWithCompletionHandler")
//      for p in protocols {
//        self.log("protocol: " + p.stringValue)
//      }
      for packet in packets {
        self.session?.writeDatagram(SVCrypto.encryptWithData(packet, userToken: nil), completionHandler: { (error: NSError?) -> Void in
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
        // currently IPv4 only
        decryptedPackets.append(SVCrypto.decryptWithData(packet, userToken: nil))
        protocols.append(2)
      }
      self.packetFlow.writePackets(decryptedPackets, withProtocols: protocols)
      }, maxDatagrams: 1024)
  }

	override func stopTunnelWithReason(reason: NEProviderStopReason, completionHandler: () -> Void) {
		// Add code here to start the process of stopping the tunnel
//    self.log("stop tunnel")
		session?.cancel()
		completionHandler()
    super.stopTunnelWithReason(reason, completionHandler: completionHandler)
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
