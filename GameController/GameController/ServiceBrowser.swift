//
//  ServiceBrowser.swift
//  GameController
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceBrowser : NSObject {
    
    private let serviceBrowser : MCNearbyServiceBrowser
    
    private let gameServiceType = "elg-escape-game"
    let kFoundPeer = "elg-foundPeer"
    let kSendInvite = "elg-sendInvite"
    let updateConnectionNotificationKey = "elg_connectionUpdate"
    let sendKeystrokesNotificationKey = "elg_sendKeystrokes"
    let kPeerIDKey = "elg-peerid"
    
    private let peerId: MCPeerID
    private var connectedPeerId: MCPeerID?
    
    private var currentBrowser: MCNearbyServiceBrowser?
    var foundPeerIds: Array<MCPeerID>?
    private var defaults: NSUserDefaults
    
    override init() {
        
        defaults = NSUserDefaults.standardUserDefaults()
        if let peerIDData = defaults.dataForKey(kPeerIDKey) {
            peerId = NSKeyedUnarchiver.unarchiveObjectWithData(peerIDData) as! MCPeerID
            print("peerID already exists: \(peerId)")
        } else {
            print("peerID does not yet exist. Create a new one.")
            peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
            let peerIDData = NSKeyedArchiver.archivedDataWithRootObject(peerId)
            defaults.setObject(peerIDData, forKey: kPeerIDKey)
            defaults.synchronize()
        }
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: gameServiceType)
        super.init()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        print("Started browsing for peers...")
        
        foundPeerIds = [MCPeerID]()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
        }()
    
    func sendInvite(notification: NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let peerIdInvite = userInfo["peerId"]
        print("Sending invite to peer: \(peerIdInvite)")
        
        var mcPeerIdInvite: MCPeerID?
        
        for id in self.foundPeerIds! {
            if id.displayName == peerIdInvite {
                mcPeerIdInvite = id
            }
        }
        
        currentBrowser!.invitePeer(mcPeerIdInvite!, toSession: self.session, withContext: nil, timeout: 15)
    }
}

extension ServiceBrowser : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        // Invite any peer discovered
        currentBrowser = browser
        
        self.foundPeerIds?.append(peerID)
        
        NSNotificationCenter.defaultCenter().postNotificationName(kFoundPeer, object: self, userInfo: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendInvite:", name: kSendInvite, object: nil)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "Not Connected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension ServiceBrowser : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.stringValue())")
        
        NSNotificationCenter.defaultCenter().postNotificationName(updateConnectionNotificationKey, object: self, userInfo: ["sessionStatus": state.stringValue()])
        
        if state == MCSessionState.Connected {
            // We are now able to send data to the game app
            connectedPeerId = peerID
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendKeystrokes:", name: sendKeystrokesNotificationKey, object: nil)
        }
        
        if state == MCSessionState.NotConnected {
            // Here must return to the main screen
            // Try sending invite again
            
        }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("peer \(peerID) didStartReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("peer \(peerID) didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveData: \(data)")
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveStream, with name: \(streamName)")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func sendKeystrokes(notification: NSNotification) {
        
        let userInfo:Dictionary<String, NSData!> = notification.userInfo as! Dictionary<String, NSData!>
        let strokeInfoData: NSData = userInfo["strokeInfo"]!
        
        var strokeInfo: Keystroke = Keystroke()
        strokeInfoData.getBytes(&strokeInfo, length: sizeof(Keystroke))
        
        do {
            try session.sendData(strokeInfoData, toPeers: [self.connectedPeerId!], withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("Error: Could not send data")
        }
    }
}